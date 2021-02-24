codeunit 50000 "FM Apartment-Post"
{
    Permissions = TableData "FM Wrk. Ord. Line" = imd,
                  TableData "FM Posted Work Order Header" = imd,
                  TableData "FM Posted Work Order Line" = imd;
    TableNo = "FM Wrk. Ord. Header";

    trigger OnRun()
    var
        SavedPreviewMode: Boolean;
        SavedSuppressCommit: Boolean;
        LinesProcessed: Boolean;
    begin
        OnBeforePostWrkOrd(Rec, SuppressCommit, PreviewMode, HideProgressWindow);
        if not GuiAllowed then
            LockTimeout(false);

        SavedPreviewMode := PreviewMode;
        SavedSuppressCommit := SuppressCommit;
        ClearAllVariables();
        SuppressCommit := SavedSuppressCommit;
        PreviewMode := SavedPreviewMode;

        GetAptSetup();
        WrkOrdHeader := Rec;
        FillTempLines(WrkOrdHeader, TempWrkOrdLineGlobal);

        EverythingPosted := true;

        // Header
        CheckAndUpdate();
        PostHeader(WrkOrdHeader, PstdWrkOrdHeader);


        // Lines
        OnBeforePostLines(TempWrkOrdLineGlobal, WrkOrdHeader, SuppressCommit, PreviewMode);

        LineCount := 0;

        LinesProcessed := false;
        if TempWrkOrdLineGlobal.FindSet() then
            repeat
                LineCount := LineCount + 1;
                if not HideProgressWindow then
                    Window.Update(2, LineCount);

                PostLine(WrkOrdHeader, TempWrkOrdLineGlobal);
            until TempWrkOrdLineGlobal.Next() = 0;

        OnAfterPostPostedLines(WrkOrdHeader, PstdWrkOrdHeader, LinesProcessed, SuppressCommit, EverythingPosted);

        UpdateLastPostingNos(WrkOrdHeader);

        OnRunOnBeforeFinalizePosting(
          WrkOrdHeader, PstdWrkOrdHeader, SuppressCommit);

        FinalizePosting(WrkOrdHeader, EverythingPosted);

        Rec := WrkOrdHeader;

        if not SuppressCommit then
            Commit();

        OnAfterPostPostedDoc(Rec, PstdWrkOrdHeader."No.", SuppressCommit);
    end;

    var
        WrkOrdHeader: Record "FM Wrk. Ord. Header";
        WrkOrdLine: Record "FM Wrk. Ord. Line";
        TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary;
        PstdWrkOrdHeader: Record "FM Posted Work Order Header";
        PstdWrkOrdLine: Record "FM Posted Work Order Line";
        AptCommentLine: Record "FM Apartment Comment Line";
        SourceCodeSetup: Record "Source Code Setup";
        ModifyHeader: Boolean;
        Window: Dialog;
        LineCount: Integer;
        PostingLinesMsg: Label 'Posting lines              #2######', Comment = 'Counter';
        PostedWrkOrdNoMsg: Label 'Work Order %1  -> Posted Work Order %2';
        PostingPreviewNoTok: Label '***', Locked = true;
        EverythingPosted: Boolean;
        SuppressCommit: Boolean;
        PreviewMode: Boolean;
        HideProgressWindow: Boolean;
        SrcCode: Code[10];
        AptSetup: Record "FM Apartment Setup";
        AptSetupRead: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeFinalizePosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedDoc(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; PstdWrkOrdHeaderNo: Code[20]; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure FinalizePosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; EverythingInvoiced: Boolean)
    begin
        OnBeforeFinalizePosting(WrkOrdHeader, TempWrkOrdLineGlobal, EverythingInvoiced, SuppressCommit);

        if not EverythingInvoiced then
            OnFinalizePostingOnNotEverythingInvoiced(WrkOrdHeader, TempWrkOrdLineGlobal, SuppressCommit)
        else
            PostUpdatePostedLine;

        if not PreviewMode then
            DeleteAfterPosting(WrkOrdHeader);

        OnAfterFinalizePostingOnBeforeCommit(WrkOrdHeader, PstdWrkOrdHeader, SuppressCommit, PreviewMode);

        if PreviewMode then begin
            if not HideProgressWindow then
                Window.Close();
            exit;
        end;
        if not SuppressCommit then
            Commit();

        if not HideProgressWindow then
            Window.Close();

        OnAfterFinalizePosting(WrkOrdHeader, PstdWrkOrdHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinalizePostingOnNotEverythingInvoiced(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFinalizePosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; var EverythingInvoiced: Boolean; SuppressCommit: Boolean)
    begin
    end;

    local procedure DeleteAfterPosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    var
        AptCommentLine: Record "FM Apartment Comment Line";
        WrkOrdLine: Record "FM Wrk. Ord. Line";
        TempWrkOrdLineLocal: Record "FM Wrk. Ord. Line" temporary;
        SkipDelete: Boolean;
    begin
        OnBeforeDeleteAfterPosting(WrkOrdHeader, PstdWrkOrdHeader, SkipDelete, SuppressCommit);
        if SkipDelete then
            exit;

        if WrkOrdHeader.HasLinks() then
            WrkOrdHeader.DeleteLinks();

        WrkOrdHeader.Delete();

        ResetTempLines(TempWrkOrdLineLocal);
        if TempWrkOrdLineLocal.FindFirst() then
            repeat
                if TempWrkOrdLineLocal.HasLinks() then
                    TempWrkOrdLineLocal.DeleteLinks();
            until TempWrkOrdLineLocal.Next() = 0;

        WrkOrdLine.SetRange("Document No.", WrkOrdHeader."No.");
        OnBeforeWrkOrdLineDeleteAll(WrkOrdLine, SuppressCommit);
        WrkOrdLine.DeleteAll();

        AptCommentLine.DeleteComments(AptCommentLine."Document Type"::"Work Order", WrkOrdHeader."No.");

        OnAfterDeleteAfterPosting(WrkOrdHeader, PstdWrkOrdHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteAfterPosting(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var SkipDelete: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWrkOrdLineDeleteAll(var WrkOrdLine: Record "FM Wrk. Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteAfterPosting(WrkOrdHeader: Record "FM Wrk. Ord. Header"; PstdWrkOrdHeader: Record "FM Posted Work Order Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure PostUpdatePostedLine()
    var
        WrkOrdLine: Record "FM Wrk. Ord. Line";
        TempWrkOrdLine: Record "FM Wrk. Ord. Line" temporary;
    begin
        ResetTempLines(TempWrkOrdLine);
        OnPostUpdatePostedLineOnBeforeFindSet(TempWrkOrdLine);
        if TempWrkOrdLine.FindSet() then
            repeat
                WrkOrdLine.Get(TempWrkOrdLine."Document No.", TempWrkOrdLine."Line No.");
                OnPostUpdatePostedLineOnBeforeModify(WrkOrdLine, TempWrkOrdLine);
                WrkOrdLine.Modify();
            until TempWrkOrdLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeFindSet(var TempWrkOrdLine: Record "FM Wrk. Ord. Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeModify(var WrkOrdLine: Record "FM Wrk. Ord. Line"; var TempWrkOrdLine: Record "FM Wrk. Ord. Line" temporary)
    begin
    end;

    local procedure ResetTempLines(var TempWrkOrdLineLocal: Record "FM Wrk. Ord. Line" temporary)
    begin
        TempWrkOrdLineLocal.Reset();
        TempWrkOrdLineLocal.Copy(TempWrkOrdLineGlobal, true);
        OnAfterResetTempLines(TempWrkOrdLineLocal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetTempLines(var TempWrkOrdLineLocal: Record "FM Wrk. Ord. Line" temporary)
    begin
    end;

    local procedure UpdateLastPostingNos(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
        WrkOrdHeader."Last Posting No." := PstdWrkOrdHeader."No.";
        WrkOrdHeader."Posting No." := '';

        OnAfterUpdateLastPostingNos(WrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLastPostingNos(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    local procedure PostLine(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var WrkOrdLine: Record "FM Wrk. Ord. Line")
    var
        IsHandled: Boolean;
    begin
        TestLine(WrkOrdHeader, WrkOrdLine);

        UpdateLineBeforePost(WrkOrdHeader, WrkOrdLine);

        IsHandled := false;
        OnPostLineOnBeforeInsertPostedLine(WrkOrdHeader, WrkOrdLine, IsHandled, PstdWrkOrdHeader);
        if not IsHandled then begin
            PstdWrkOrdLine.Init();
            PstdWrkOrdLine.TransferFields(WrkOrdLine);
            PstdWrkOrdLine."Document No." := PstdWrkOrdHeader."No.";

            OnBeforePostedLineInsert(PstdWrkOrdLine, PstdWrkOrdHeader, TempWrkOrdLineGlobal, WrkOrdHeader, SrcCode, SuppressCommit);
            PstdWrkOrdLine.Insert(true);
            OnAfterPostedLineInsert(PstdWrkOrdLine, PstdWrkOrdHeader, TempWrkOrdLineGlobal, WrkOrdHeader, SrcCode, SuppressCommit);
        end;

        OnAfterPostPostedLine(WrkOrdHeader, WrkOrdLine, SuppressCommit, PstdWrkOrdLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLineOnBeforeInsertPostedLine(WrkOrdHeader: Record "FM Wrk. Ord. Header"; WrkOrdLine: Record "FM Wrk. Ord. Line"; var IsHandled: Boolean; PstdWrkOrdHeader: Record "FM Posted Work Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedLineInsert(var PstdWrkOrdLine: Record "FM Posted Work Order Line"; PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; WrkOrdHeader: Record "FM Wrk. Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedLineInsert(var PstdWrkOrdLine: Record "FM Posted Work Order Line"; PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; WrkOrdHeader: Record "FM Wrk. Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLine(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var WrkOrdLine: Record "FM Wrk. Ord. Line"; CommitIsSuppressed: Boolean; var PstdWrkOrdLine: Record "FM Posted Work Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLines(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var LinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingPosted: Boolean)
    begin
    end;

    local procedure TestLine(WrkOrdHeader: Record "FM Wrk. Ord. Header"; WrkOrdLine: Record "FM Wrk. Ord. Line")
    begin
        OnTestLine(WrkOrdHeader, WrkOrdLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestLine(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var WrkOrdLine: Record "FM Wrk. Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure UpdateLineBeforePost(WrkOrdHeader: Record "FM Wrk. Ord. Header"; WrkOrdLine: Record "FM Wrk. Ord. Line")
    begin
        OnUpdateLineBeforePost(WrkOrdHeader, WrkOrdLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineBeforePost(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var WrkOrdLine: Record "FM Wrk. Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure ClearAllVariables()
    begin
        ClearAll;
        TempWrkOrdLineGlobal.DeleteAll();
    end;

    procedure FillTempLines(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLine: Record "FM Wrk. Ord. Line" temporary)
    begin
        TempWrkOrdLine.Reset();
        if TempWrkOrdLine.IsEmpty() then
            CopyToTempLines(WrkOrdHeader, TempWrkOrdLine);
    end;

    procedure CopyToTempLines(WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLine: Record "FM Wrk. Ord. Line" temporary)
    var
        WrkOrdLine: Record "FM Wrk. Ord. Line";
    begin
        WrkOrdLine.SetRange("Document No.", WrkOrdHeader."No.");
        OnCopyToTempLinesOnAfterSetFilters(WrkOrdLine, WrkOrdHeader);
        if WrkOrdLine.FindSet() then
            repeat
                TempWrkOrdLine := WrkOrdLine;
                TempWrkOrdLine.Insert();
            until WrkOrdLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyToTempLinesOnAfterSetFilters(var WrkOrdLine: Record "FM Wrk. Ord. Line"; WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforePostLines(var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    local procedure PostHeader(WrkOrdHeader: Record "FM Wrk. Ord. Header"; PstdWrkOrdHeader: Record "FM Posted Work Order Header")
    begin
        OnPostHeader(WrkOrdHeader, PstdWrkOrdHeader, TempWrkOrdLineGlobal, SrcCode, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostHeader(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; SrcCode: Code[10]; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure CheckAndUpdate()
    begin
        // Check
        CheckMandatoryHeaderFields(WrkOrdHeader);
        CheckPostRestrictions(WrkOrdHeader);

        if not HideProgressWindow then
            InitProgressWindow(WrkOrdHeader);

        CheckNothingToPost(WrkOrdHeader);

        OnAfterCheckWrkOrd(WrkOrdHeader, SuppressCommit);

        // Update
        ModifyHeader := UpdatePostingNo(WrkOrdHeader);

        OnBeforePostCommitWrkOrd(WrkOrdHeader, PreviewMode, ModifyHeader, SuppressCommit, TempWrkOrdLineGlobal);
        if not PreviewMode and ModifyHeader then begin
            WrkOrdHeader.Modify();
            if not SuppressCommit then
                Commit();
        end;

        LockTables(WrkOrdHeader);

        SourceCodeSetup.Get();
        SrcCode := SourceCodeSetup."Work Order";

        OnCheckAndUpdateOnAfterSetSourceCode(WrkOrdHeader, SourceCodeSetup, SrcCode);

        InsertPostedHeaders(WrkOrdHeader);

        OnAfterCheckAndUpdate(WrkOrdHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAndUpdate(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure InsertPostedHeaders(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        IsHandled: Boolean;
    begin
        if PreviewMode then
            PostingPreviewEventHandler.PreventCommit();

        PstdWrkOrdHeader.LockTable();

        IsHandled := false;
        OnBeforeInsertPstdWrkOrdHeader(WrkOrdHeader, IsHandled);
        if not IsHandled then
            InsertPstdWrkOrdHeader(WrkOrdHeader, PstdWrkOrdHeader);

        OnAfterInsertPstdWrkOrdHeader(WrkOrdHeader, PstdWrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPstdWrkOrdHeader(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPstdWrkOrdHeader(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; PstdWrkOrdHeader: Record "FM Posted Work Order Header")
    begin
    end;

    local procedure InsertPstdWrkOrdHeader(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var PstdWrkOrdHeader: Record "FM Posted Work Order Header")
    var
        AptCommentLine: Record "FM Apartment Comment Line";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        PstdWrkOrdHeader.Init();
        PstdWrkOrdHeader.TransferFields(WrkOrdHeader);

        PstdWrkOrdHeader."No." := WrkOrdHeader."Posting No.";
        PstdWrkOrdHeader."No. Series" := WrkOrdHeader."Posting No. Series";
        PstdWrkOrdHeader."Wrk. Ord. No." := WrkOrdHeader."No.";
        PstdWrkOrdHeader."Wrk. Ord. Nos." := WrkOrdHeader."No. Series";
        if GuiAllowed and not HideProgressWindow then
            Window.Update(1, StrSubstNo(PostedWrkOrdNoMsg, WrkOrdHeader."No.", PstdWrkOrdHeader."No."));
        PstdWrkOrdHeader."Source Code" := SrcCode;
        PstdWrkOrdHeader."User ID" := UserId();
        PstdWrkOrdHeader."No. Printed" := 0;

        OnBeforePstdWrkOrdHeaderInsert(PstdWrkOrdHeader, WrkOrdHeader, SuppressCommit);
        PstdWrkOrdHeader.Insert(true);
        OnAfterPstdWrkOrdHeaderInsert(PstdWrkOrdHeader, WrkOrdHeader, SuppressCommit);

        if AptSetup."Copy Comments" then begin
            AptCommentLine.CopyComments(AptCommentLine."Document Type"::"Work Order", AptCommentLine."Document Type"::"Posted Work Order", WrkOrdHeader."No.", PstdWrkOrdHeader."No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePstdWrkOrdHeaderInsert(var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPstdWrkOrdHeaderInsert(var PstdWrkOrdHeader: Record "FM Posted Work Order Header"; WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckAndUpdateOnAfterSetSourceCode(WrkOrdHeader: Record "FM Wrk. Ord. Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    begin
    end;

    local procedure LockTables(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    var
        WrkOrdLine: Record "FM Wrk. Ord. Line";
    begin
        OnBeforeLockTables(WrkOrdHeader, PreviewMode, SuppressCommit);

        WrkOrdLine.LockTable();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLockTables(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCommitWrkOrd(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary)
    begin
    end;

    local procedure UpdatePostingNo(var WrkOrdHeader: Record "FM Wrk. Ord. Header") ModifyHeader: Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        OnBeforeUpdatePostingNo(WrkOrdHeader, PreviewMode, ModifyHeader, IsHandled);

        if not IsHandled then
            if WrkOrdHeader."Posting No." = '' then
                if not PreviewMode then begin
                    WrkOrdHeader.TestField("Posting No. Series");
                    WrkOrdHeader."Posting No." := NoSeriesMgt.GetNextNo(WrkOrdHeader."Posting No. Series", WrkOrdHeader."Posting Date", true);
                    ModifyHeader := true;
                end else
                    WrkOrdHeader."Posting No." := PostingPreviewNoTok;

        OnAfterUpdatePostingNo(WrkOrdHeader, NoSeriesMgt, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePostingNo(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePostingNo(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var NoSeriesMgt: Codeunit NoSeriesManagement; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckWrkOrd(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    procedure InitProgressWindow(WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
        Window.Open(
                '#1#################################\\' +
                  PostingLinesMsg);
        Window.Update(1, StrSubstNo('%1', WrkOrdHeader."No."));
    end;

    local procedure CheckMandatoryHeaderFields(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckMandatoryFields(WrkOrdHeader, SuppressCommit, IsHandled);
        if not IsHandled then begin
            WrkOrdHeader.TestField("Posting Date");
        end;

        OnAfterCheckMandatoryFields(WrkOrdHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckMandatoryFields(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckMandatoryFields(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure CheckPostRestrictions(WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
        OnCheckPostRestrictions(WrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostRestrictions(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

    local procedure CheckNothingToPost(WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
        OnCheckNothingToPost(WrkOrdHeader, TempWrkOrdLineGlobal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckNothingToPost(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostWrkOrd(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    begin
    end;

    local procedure GetAptSetup()
    begin
        if not AptSetupRead then
            AptSetup.Get;

        AptSetupRead := true;

        OnAfterGetAptSetup(AptSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAptSetup(var AptSetup: Record "FM Apartment Setup")
    begin
    end;

}
