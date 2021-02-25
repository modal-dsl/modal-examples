codeunit 50040 "LM Patient-Post"
{
    Permissions = TableData "LM Bld. Test Line" = imd,
                  TableData "LM Posted Blood Test Header" = imd,
                  TableData "LM Posted Blood Test Line" = imd;
    TableNo = "LM Bld. Test Header";

    trigger OnRun()
    var
        SavedPreviewMode: Boolean;
        SavedSuppressCommit: Boolean;
        LinesProcessed: Boolean;
    begin
        OnBeforePostBldTest(Rec, SuppressCommit, PreviewMode, HideProgressWindow);
        if not GuiAllowed then
            LockTimeout(false);

        SavedPreviewMode := PreviewMode;
        SavedSuppressCommit := SuppressCommit;
        ClearAllVariables();
        SuppressCommit := SavedSuppressCommit;
        PreviewMode := SavedPreviewMode;

        GetPatSetup();
        BldTestHeader := Rec;
        FillTempLines(BldTestHeader, TempBldTestLineGlobal);

        EverythingPosted := true;

        // Header
        CheckAndUpdate();
        PostHeader(BldTestHeader, PstdBldTestHeader);


        // Lines
        OnBeforePostLines(TempBldTestLineGlobal, BldTestHeader, SuppressCommit, PreviewMode);

        LineCount := 0;

        LinesProcessed := false;
        if TempBldTestLineGlobal.FindSet() then
            repeat
                LineCount := LineCount + 1;
                if not HideProgressWindow then
                    Window.Update(2, LineCount);

                PostLine(BldTestHeader, TempBldTestLineGlobal);
            until TempBldTestLineGlobal.Next() = 0;

        OnAfterPostPostedLines(BldTestHeader, PstdBldTestHeader, LinesProcessed, SuppressCommit, EverythingPosted);

        UpdateLastPostingNos(BldTestHeader);

        OnRunOnBeforeFinalizePosting(
          BldTestHeader, PstdBldTestHeader, SuppressCommit);

        FinalizePosting(BldTestHeader, EverythingPosted);

        Rec := BldTestHeader;

        if not SuppressCommit then
            Commit();

        OnAfterPostPostedDoc(Rec, PstdBldTestHeader."No.", SuppressCommit);
    end;

    var
        BldTestHeader: Record "LM Bld. Test Header";
        BldTestLine: Record "LM Bld. Test Line";
        TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary;
        PstdBldTestHeader: Record "LM Posted Blood Test Header";
        PstdBldTestLine: Record "LM Posted Blood Test Line";
        PatCommentLine: Record "LM Patient Comment Line";
        SourceCodeSetup: Record "Source Code Setup";
        ModifyHeader: Boolean;
        Window: Dialog;
        LineCount: Integer;
        PostingLinesMsg: Label 'Posting lines              #2######', Comment = 'Counter';
        PostedBldTestNoMsg: Label 'Blood Test %1  -> Posted Blood Test %2';
        PostingPreviewNoTok: Label '***', Locked = true;
        EverythingPosted: Boolean;
        SuppressCommit: Boolean;
        PreviewMode: Boolean;
        HideProgressWindow: Boolean;
        SrcCode: Code[10];
        PatSetup: Record "LM Patient Setup";
        PatSetupRead: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeFinalizePosting(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedDoc(var BldTestHeader: Record "LM Bld. Test Header"; PstdBldTestHeaderNo: Code[20]; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure FinalizePosting(var BldTestHeader: Record "LM Bld. Test Header"; EverythingInvoiced: Boolean)
    begin
        OnBeforeFinalizePosting(BldTestHeader, TempBldTestLineGlobal, EverythingInvoiced, SuppressCommit);

        if not EverythingInvoiced then
            OnFinalizePostingOnNotEverythingInvoiced(BldTestHeader, TempBldTestLineGlobal, SuppressCommit)
        else
            PostUpdatePostedLine;

        if not PreviewMode then
            DeleteAfterPosting(BldTestHeader);

        OnAfterFinalizePostingOnBeforeCommit(BldTestHeader, PstdBldTestHeader, SuppressCommit, PreviewMode);

        if PreviewMode then begin
            if not HideProgressWindow then
                Window.Close();
            exit;
        end;
        if not SuppressCommit then
            Commit();

        if not HideProgressWindow then
            Window.Close();

        OnAfterFinalizePosting(BldTestHeader, PstdBldTestHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinalizePostingOnNotEverythingInvoiced(var BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePosting(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFinalizePosting(var BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; var EverythingInvoiced: Boolean; SuppressCommit: Boolean)
    begin
    end;

    local procedure DeleteAfterPosting(var BldTestHeader: Record "LM Bld. Test Header")
    var
        PatCommentLine: Record "LM Patient Comment Line";
        BldTestLine: Record "LM Bld. Test Line";
        TempBldTestLineLocal: Record "LM Bld. Test Line" temporary;
        SkipDelete: Boolean;
    begin
        OnBeforeDeleteAfterPosting(BldTestHeader, PstdBldTestHeader, SkipDelete, SuppressCommit);
        if SkipDelete then
            exit;

        if BldTestHeader.HasLinks() then
            BldTestHeader.DeleteLinks();

        BldTestHeader.Delete();

        ResetTempLines(TempBldTestLineLocal);
        if TempBldTestLineLocal.FindFirst() then
            repeat
                if TempBldTestLineLocal.HasLinks() then
                    TempBldTestLineLocal.DeleteLinks();
            until TempBldTestLineLocal.Next() = 0;

        BldTestLine.SetRange("Document No.", BldTestHeader."No.");
        OnBeforeBldTestLineDeleteAll(BldTestLine, SuppressCommit);
        BldTestLine.DeleteAll();

        PatCommentLine.DeleteComments(PatCommentLine."Document Type"::"Blood Test", BldTestHeader."No.");

        OnAfterDeleteAfterPosting(BldTestHeader, PstdBldTestHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteAfterPosting(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; var SkipDelete: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBldTestLineDeleteAll(var BldTestLine: Record "LM Bld. Test Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteAfterPosting(BldTestHeader: Record "LM Bld. Test Header"; PstdBldTestHeader: Record "LM Posted Blood Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure PostUpdatePostedLine()
    var
        BldTestLine: Record "LM Bld. Test Line";
        TempBldTestLine: Record "LM Bld. Test Line" temporary;
    begin
        ResetTempLines(TempBldTestLine);
        OnPostUpdatePostedLineOnBeforeFindSet(TempBldTestLine);
        if TempBldTestLine.FindSet() then
            repeat
                BldTestLine.Get(TempBldTestLine."Document No.", TempBldTestLine."Line No.");
                OnPostUpdatePostedLineOnBeforeModify(BldTestLine, TempBldTestLine);
                BldTestLine.Modify();
            until TempBldTestLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeFindSet(var TempBldTestLine: Record "LM Bld. Test Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeModify(var BldTestLine: Record "LM Bld. Test Line"; var TempBldTestLine: Record "LM Bld. Test Line" temporary)
    begin
    end;

    local procedure ResetTempLines(var TempBldTestLineLocal: Record "LM Bld. Test Line" temporary)
    begin
        TempBldTestLineLocal.Reset();
        TempBldTestLineLocal.Copy(TempBldTestLineGlobal, true);
        OnAfterResetTempLines(TempBldTestLineLocal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetTempLines(var TempBldTestLineLocal: Record "LM Bld. Test Line" temporary)
    begin
    end;

    local procedure UpdateLastPostingNos(var BldTestHeader: Record "LM Bld. Test Header")
    begin
        BldTestHeader."Last Posting No." := PstdBldTestHeader."No.";
        BldTestHeader."Posting No." := '';

        OnAfterUpdateLastPostingNos(BldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLastPostingNos(var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    local procedure PostLine(var BldTestHeader: Record "LM Bld. Test Header"; var BldTestLine: Record "LM Bld. Test Line")
    var
        IsHandled: Boolean;
    begin
        TestLine(BldTestHeader, BldTestLine);

        UpdateLineBeforePost(BldTestHeader, BldTestLine);

        IsHandled := false;
        OnPostLineOnBeforeInsertPostedLine(BldTestHeader, BldTestLine, IsHandled, PstdBldTestHeader);
        if not IsHandled then begin
            PstdBldTestLine.Init();
            PstdBldTestLine.TransferFields(BldTestLine);
            PstdBldTestLine."Document No." := PstdBldTestHeader."No.";

            OnBeforePostedLineInsert(PstdBldTestLine, PstdBldTestHeader, TempBldTestLineGlobal, BldTestHeader, SrcCode, SuppressCommit);
            PstdBldTestLine.Insert(true);
            OnAfterPostedLineInsert(PstdBldTestLine, PstdBldTestHeader, TempBldTestLineGlobal, BldTestHeader, SrcCode, SuppressCommit);
        end;

        OnAfterPostPostedLine(BldTestHeader, BldTestLine, SuppressCommit, PstdBldTestLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLineOnBeforeInsertPostedLine(BldTestHeader: Record "LM Bld. Test Header"; BldTestLine: Record "LM Bld. Test Line"; var IsHandled: Boolean; PstdBldTestHeader: Record "LM Posted Blood Test Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedLineInsert(var PstdBldTestLine: Record "LM Posted Blood Test Line"; PstdBldTestHeader: Record "LM Posted Blood Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; BldTestHeader: Record "LM Bld. Test Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedLineInsert(var PstdBldTestLine: Record "LM Posted Blood Test Line"; PstdBldTestHeader: Record "LM Posted Blood Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; BldTestHeader: Record "LM Bld. Test Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLine(var BldTestHeader: Record "LM Bld. Test Header"; var BldTestLine: Record "LM Bld. Test Line"; CommitIsSuppressed: Boolean; var PstdBldTestLine: Record "LM Posted Blood Test Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLines(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; var LinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingPosted: Boolean)
    begin
    end;

    local procedure TestLine(BldTestHeader: Record "LM Bld. Test Header"; BldTestLine: Record "LM Bld. Test Line")
    begin
        OnTestLine(BldTestHeader, BldTestLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestLine(var BldTestHeader: Record "LM Bld. Test Header"; var BldTestLine: Record "LM Bld. Test Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure UpdateLineBeforePost(BldTestHeader: Record "LM Bld. Test Header"; BldTestLine: Record "LM Bld. Test Line")
    begin
        OnUpdateLineBeforePost(BldTestHeader, BldTestLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineBeforePost(var BldTestHeader: Record "LM Bld. Test Header"; var BldTestLine: Record "LM Bld. Test Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure ClearAllVariables()
    begin
        ClearAll;
        TempBldTestLineGlobal.DeleteAll();
    end;

    procedure FillTempLines(BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLine: Record "LM Bld. Test Line" temporary)
    begin
        TempBldTestLine.Reset();
        if TempBldTestLine.IsEmpty() then
            CopyToTempLines(BldTestHeader, TempBldTestLine);
    end;

    procedure CopyToTempLines(BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLine: Record "LM Bld. Test Line" temporary)
    var
        BldTestLine: Record "LM Bld. Test Line";
    begin
        BldTestLine.SetRange("Document No.", BldTestHeader."No.");
        OnCopyToTempLinesOnAfterSetFilters(BldTestLine, BldTestHeader);
        if BldTestLine.FindSet() then
            repeat
                TempBldTestLine := BldTestLine;
                TempBldTestLine.Insert();
            until BldTestLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyToTempLinesOnAfterSetFilters(var BldTestLine: Record "LM Bld. Test Line"; BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforePostLines(var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
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

    local procedure PostHeader(BldTestHeader: Record "LM Bld. Test Header"; PstdBldTestHeader: Record "LM Posted Blood Test Header")
    begin
        OnPostHeader(BldTestHeader, PstdBldTestHeader, TempBldTestLineGlobal, SrcCode, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostHeader(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; SrcCode: Code[10]; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure CheckAndUpdate()
    begin
        // Check
        CheckMandatoryHeaderFields(BldTestHeader);
        CheckPostRestrictions(BldTestHeader);

        if not HideProgressWindow then
            InitProgressWindow(BldTestHeader);

        CheckNothingToPost(BldTestHeader);

        OnAfterCheckBldTest(BldTestHeader, SuppressCommit);

        // Update
        ModifyHeader := UpdatePostingNo(BldTestHeader);

        OnBeforePostCommitBldTest(BldTestHeader, PreviewMode, ModifyHeader, SuppressCommit, TempBldTestLineGlobal);
        if not PreviewMode and ModifyHeader then begin
            BldTestHeader.Modify();
            if not SuppressCommit then
                Commit();
        end;

        LockTables(BldTestHeader);

        SourceCodeSetup.Get();
        SrcCode := SourceCodeSetup."Blood Test";

        OnCheckAndUpdateOnAfterSetSourceCode(BldTestHeader, SourceCodeSetup, SrcCode);

        InsertPostedHeaders(BldTestHeader);

        OnAfterCheckAndUpdate(BldTestHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAndUpdate(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure InsertPostedHeaders(var BldTestHeader: Record "LM Bld. Test Header")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        IsHandled: Boolean;
    begin
        if PreviewMode then
            PostingPreviewEventHandler.PreventCommit();

        PstdBldTestHeader.LockTable();

        IsHandled := false;
        OnBeforeInsertPstdBldTestHeader(BldTestHeader, IsHandled);
        if not IsHandled then
            InsertPstdBldTestHeader(BldTestHeader, PstdBldTestHeader);

        OnAfterInsertPstdBldTestHeader(BldTestHeader, PstdBldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPstdBldTestHeader(var BldTestHeader: Record "LM Bld. Test Header"; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPstdBldTestHeader(var BldTestHeader: Record "LM Bld. Test Header"; PstdBldTestHeader: Record "LM Posted Blood Test Header")
    begin
    end;

    local procedure InsertPstdBldTestHeader(var BldTestHeader: Record "LM Bld. Test Header"; var PstdBldTestHeader: Record "LM Posted Blood Test Header")
    var
        PatCommentLine: Record "LM Patient Comment Line";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        PstdBldTestHeader.Init();
        PstdBldTestHeader.TransferFields(BldTestHeader);

        PstdBldTestHeader."No." := BldTestHeader."Posting No.";
        PstdBldTestHeader."No. Series" := BldTestHeader."Posting No. Series";
        PstdBldTestHeader."Bld. Test No." := BldTestHeader."No.";
        PstdBldTestHeader."Bld. Test Nos." := BldTestHeader."No. Series";
        if GuiAllowed and not HideProgressWindow then
            Window.Update(1, StrSubstNo(PostedBldTestNoMsg, BldTestHeader."No.", PstdBldTestHeader."No."));
        PstdBldTestHeader."Source Code" := SrcCode;
        PstdBldTestHeader."User ID" := UserId();
        PstdBldTestHeader."No. Printed" := 0;

        OnBeforePstdBldTestHeaderInsert(PstdBldTestHeader, BldTestHeader, SuppressCommit);
        PstdBldTestHeader.Insert(true);
        OnAfterPstdBldTestHeaderInsert(PstdBldTestHeader, BldTestHeader, SuppressCommit);

        if PatSetup."Copy Comments" then begin
            PatCommentLine.CopyComments(PatCommentLine."Document Type"::"Blood Test", PatCommentLine."Document Type"::"Posted Blood Test", BldTestHeader."No.", PstdBldTestHeader."No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePstdBldTestHeaderInsert(var PstdBldTestHeader: Record "LM Posted Blood Test Header"; BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPstdBldTestHeaderInsert(var PstdBldTestHeader: Record "LM Posted Blood Test Header"; BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckAndUpdateOnAfterSetSourceCode(BldTestHeader: Record "LM Bld. Test Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    begin
    end;

    local procedure LockTables(var BldTestHeader: Record "LM Bld. Test Header")
    var
        BldTestLine: Record "LM Bld. Test Line";
    begin
        OnBeforeLockTables(BldTestHeader, PreviewMode, SuppressCommit);

        BldTestLine.LockTable();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLockTables(var BldTestHeader: Record "LM Bld. Test Header"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCommitBldTest(var BldTestHeader: Record "LM Bld. Test Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary)
    begin
    end;

    local procedure UpdatePostingNo(var BldTestHeader: Record "LM Bld. Test Header") ModifyHeader: Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        OnBeforeUpdatePostingNo(BldTestHeader, PreviewMode, ModifyHeader, IsHandled);

        if not IsHandled then
            if BldTestHeader."Posting No." = '' then
                if not PreviewMode then begin
                    BldTestHeader.TestField("Posting No. Series");
                    BldTestHeader."Posting No." := NoSeriesMgt.GetNextNo(BldTestHeader."Posting No. Series", BldTestHeader."Posting Date", true);
                    ModifyHeader := true;
                end else
                    BldTestHeader."Posting No." := PostingPreviewNoTok;

        OnAfterUpdatePostingNo(BldTestHeader, NoSeriesMgt, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePostingNo(var BldTestHeader: Record "LM Bld. Test Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePostingNo(var BldTestHeader: Record "LM Bld. Test Header"; var NoSeriesMgt: Codeunit NoSeriesManagement; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckBldTest(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    procedure InitProgressWindow(BldTestHeader: Record "LM Bld. Test Header")
    begin
        Window.Open(
                '#1#################################\\' +
                  PostingLinesMsg);
        Window.Update(1, StrSubstNo('%1', BldTestHeader."No."));
    end;

    local procedure CheckMandatoryHeaderFields(var BldTestHeader: Record "LM Bld. Test Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckMandatoryFields(BldTestHeader, SuppressCommit, IsHandled);
        if not IsHandled then begin
            BldTestHeader.TestField("Posting Date");
        end;

        OnAfterCheckMandatoryFields(BldTestHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckMandatoryFields(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckMandatoryFields(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure CheckPostRestrictions(BldTestHeader: Record "LM Bld. Test Header")
    begin
        OnCheckPostRestrictions(BldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostRestrictions(var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

    local procedure CheckNothingToPost(BldTestHeader: Record "LM Bld. Test Header")
    begin
        OnCheckNothingToPost(BldTestHeader, TempBldTestLineGlobal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckNothingToPost(var BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostBldTest(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    begin
    end;

    local procedure GetPatSetup()
    begin
        if not PatSetupRead then
            PatSetup.Get;

        PatSetupRead := true;

        OnAfterGetPatSetup(PatSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPatSetup(var PatSetup: Record "LM Patient Setup")
    begin
    end;

}
