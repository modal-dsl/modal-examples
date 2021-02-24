codeunit 50020 "LM Book-Post"
{
    Permissions = TableData "LM Loan Ord. Line" = imd,
                  TableData "LM Posted Loan Order Header" = imd,
                  TableData "LM Posted Loan Order Line" = imd;
    TableNo = "LM Loan Ord. Header";

    trigger OnRun()
    var
        SavedPreviewMode: Boolean;
        SavedSuppressCommit: Boolean;
        LinesProcessed: Boolean;
    begin
        OnBeforePostLoanOrd(Rec, SuppressCommit, PreviewMode, HideProgressWindow);
        if not GuiAllowed then
            LockTimeout(false);

        SavedPreviewMode := PreviewMode;
        SavedSuppressCommit := SuppressCommit;
        ClearAllVariables();
        SuppressCommit := SavedSuppressCommit;
        PreviewMode := SavedPreviewMode;

        GetBookSetup();
        LoanOrdHeader := Rec;
        FillTempLines(LoanOrdHeader, TempLoanOrdLineGlobal);

        EverythingPosted := true;

        // Header
        CheckAndUpdate();
        PostHeader(LoanOrdHeader, PstdLoanOrdHeader);


        // Lines
        OnBeforePostLines(TempLoanOrdLineGlobal, LoanOrdHeader, SuppressCommit, PreviewMode);

        LineCount := 0;

        LinesProcessed := false;
        if TempLoanOrdLineGlobal.FindSet() then
            repeat
                LineCount := LineCount + 1;
                if not HideProgressWindow then
                    Window.Update(2, LineCount);

                PostLine(LoanOrdHeader, TempLoanOrdLineGlobal);
            until TempLoanOrdLineGlobal.Next() = 0;

        OnAfterPostPostedLines(LoanOrdHeader, PstdLoanOrdHeader, LinesProcessed, SuppressCommit, EverythingPosted);

        UpdateLastPostingNos(LoanOrdHeader);

        OnRunOnBeforeFinalizePosting(
          LoanOrdHeader, PstdLoanOrdHeader, SuppressCommit);

        FinalizePosting(LoanOrdHeader, EverythingPosted);

        Rec := LoanOrdHeader;

        if not SuppressCommit then
            Commit();

        OnAfterPostPostedDoc(Rec, PstdLoanOrdHeader."No.", SuppressCommit);
    end;

    var
        LoanOrdHeader: Record "LM Loan Ord. Header";
        LoanOrdLine: Record "LM Loan Ord. Line";
        TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary;
        PstdLoanOrdHeader: Record "LM Posted Loan Order Header";
        PstdLoanOrdLine: Record "LM Posted Loan Order Line";
        BookCommentLine: Record "LM Book Comment Line";
        SourceCodeSetup: Record "Source Code Setup";
        ModifyHeader: Boolean;
        Window: Dialog;
        LineCount: Integer;
        PostingLinesMsg: Label 'Posting lines              #2######', Comment = 'Counter';
        PostedLoanOrdNoMsg: Label 'Loan Order %1  -> Posted Loan Order %2';
        PostingPreviewNoTok: Label '***', Locked = true;
        EverythingPosted: Boolean;
        SuppressCommit: Boolean;
        PreviewMode: Boolean;
        HideProgressWindow: Boolean;
        SrcCode: Code[10];
        BookSetup: Record "LM Book Setup";
        BookSetupRead: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeFinalizePosting(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedDoc(var LoanOrdHeader: Record "LM Loan Ord. Header"; PstdLoanOrdHeaderNo: Code[20]; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure FinalizePosting(var LoanOrdHeader: Record "LM Loan Ord. Header"; EverythingInvoiced: Boolean)
    begin
        OnBeforeFinalizePosting(LoanOrdHeader, TempLoanOrdLineGlobal, EverythingInvoiced, SuppressCommit);

        if not EverythingInvoiced then
            OnFinalizePostingOnNotEverythingInvoiced(LoanOrdHeader, TempLoanOrdLineGlobal, SuppressCommit)
        else
            PostUpdatePostedLine;

        if not PreviewMode then
            DeleteAfterPosting(LoanOrdHeader);

        OnAfterFinalizePostingOnBeforeCommit(LoanOrdHeader, PstdLoanOrdHeader, SuppressCommit, PreviewMode);

        if PreviewMode then begin
            if not HideProgressWindow then
                Window.Close();
            exit;
        end;
        if not SuppressCommit then
            Commit();

        if not HideProgressWindow then
            Window.Close();

        OnAfterFinalizePosting(LoanOrdHeader, PstdLoanOrdHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinalizePostingOnNotEverythingInvoiced(var LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; SuppressCommit: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePostingOnBeforeCommit(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFinalizePosting(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFinalizePosting(var LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; var EverythingInvoiced: Boolean; SuppressCommit: Boolean)
    begin
    end;

    local procedure DeleteAfterPosting(var LoanOrdHeader: Record "LM Loan Ord. Header")
    var
        BookCommentLine: Record "LM Book Comment Line";
        LoanOrdLine: Record "LM Loan Ord. Line";
        TempLoanOrdLineLocal: Record "LM Loan Ord. Line" temporary;
        SkipDelete: Boolean;
    begin
        OnBeforeDeleteAfterPosting(LoanOrdHeader, PstdLoanOrdHeader, SkipDelete, SuppressCommit);
        if SkipDelete then
            exit;

        if LoanOrdHeader.HasLinks() then
            LoanOrdHeader.DeleteLinks();

        LoanOrdHeader.Delete();

        ResetTempLines(TempLoanOrdLineLocal);
        if TempLoanOrdLineLocal.FindFirst() then
            repeat
                if TempLoanOrdLineLocal.HasLinks() then
                    TempLoanOrdLineLocal.DeleteLinks();
            until TempLoanOrdLineLocal.Next() = 0;

        LoanOrdLine.SetRange("Document No.", LoanOrdHeader."No.");
        OnBeforeLoanOrdLineDeleteAll(LoanOrdLine, SuppressCommit);
        LoanOrdLine.DeleteAll();

        BookCommentLine.DeleteComments(BookCommentLine."Document Type"::"Loan Order", LoanOrdHeader."No.");

        OnAfterDeleteAfterPosting(LoanOrdHeader, PstdLoanOrdHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteAfterPosting(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var SkipDelete: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLoanOrdLineDeleteAll(var LoanOrdLine: Record "LM Loan Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDeleteAfterPosting(LoanOrdHeader: Record "LM Loan Ord. Header"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure PostUpdatePostedLine()
    var
        LoanOrdLine: Record "LM Loan Ord. Line";
        TempLoanOrdLine: Record "LM Loan Ord. Line" temporary;
    begin
        ResetTempLines(TempLoanOrdLine);
        OnPostUpdatePostedLineOnBeforeFindSet(TempLoanOrdLine);
        if TempLoanOrdLine.FindSet() then
            repeat
                LoanOrdLine.Get(TempLoanOrdLine."Document No.", TempLoanOrdLine."Line No.");
                OnPostUpdatePostedLineOnBeforeModify(LoanOrdLine, TempLoanOrdLine);
                LoanOrdLine.Modify();
            until TempLoanOrdLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeFindSet(var TempLoanOrdLine: Record "LM Loan Ord. Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostUpdatePostedLineOnBeforeModify(var LoanOrdLine: Record "LM Loan Ord. Line"; var TempLoanOrdLine: Record "LM Loan Ord. Line" temporary)
    begin
    end;

    local procedure ResetTempLines(var TempLoanOrdLineLocal: Record "LM Loan Ord. Line" temporary)
    begin
        TempLoanOrdLineLocal.Reset();
        TempLoanOrdLineLocal.Copy(TempLoanOrdLineGlobal, true);
        OnAfterResetTempLines(TempLoanOrdLineLocal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterResetTempLines(var TempLoanOrdLineLocal: Record "LM Loan Ord. Line" temporary)
    begin
    end;

    local procedure UpdateLastPostingNos(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
        LoanOrdHeader."Last Posting No." := PstdLoanOrdHeader."No.";
        LoanOrdHeader."Posting No." := '';

        OnAfterUpdateLastPostingNos(LoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLastPostingNos(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    local procedure PostLine(var LoanOrdHeader: Record "LM Loan Ord. Header"; var LoanOrdLine: Record "LM Loan Ord. Line")
    var
        IsHandled: Boolean;
    begin
        TestLine(LoanOrdHeader, LoanOrdLine);

        UpdateLineBeforePost(LoanOrdHeader, LoanOrdLine);

        IsHandled := false;
        OnPostLineOnBeforeInsertPostedLine(LoanOrdHeader, LoanOrdLine, IsHandled, PstdLoanOrdHeader);
        if not IsHandled then begin
            PstdLoanOrdLine.Init();
            PstdLoanOrdLine.TransferFields(LoanOrdLine);
            PstdLoanOrdLine."Document No." := PstdLoanOrdHeader."No.";

            OnBeforePostedLineInsert(PstdLoanOrdLine, PstdLoanOrdHeader, TempLoanOrdLineGlobal, LoanOrdHeader, SrcCode, SuppressCommit);
            PstdLoanOrdLine.Insert(true);
            OnAfterPostedLineInsert(PstdLoanOrdLine, PstdLoanOrdHeader, TempLoanOrdLineGlobal, LoanOrdHeader, SrcCode, SuppressCommit);
        end;

        OnAfterPostPostedLine(LoanOrdHeader, LoanOrdLine, SuppressCommit, PstdLoanOrdLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostLineOnBeforeInsertPostedLine(LoanOrdHeader: Record "LM Loan Ord. Header"; LoanOrdLine: Record "LM Loan Ord. Line"; var IsHandled: Boolean; PstdLoanOrdHeader: Record "LM Posted Loan Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostedLineInsert(var PstdLoanOrdLine: Record "LM Posted Loan Order Line"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; LoanOrdHeader: Record "LM Loan Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostedLineInsert(var PstdLoanOrdLine: Record "LM Posted Loan Order Line"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; LoanOrdHeader: Record "LM Loan Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLine(var LoanOrdHeader: Record "LM Loan Ord. Header"; var LoanOrdLine: Record "LM Loan Ord. Line"; CommitIsSuppressed: Boolean; var PstdLoanOrdLine: Record "LM Posted Loan Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPostedLines(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var LinesProcessed: Boolean; CommitIsSuppressed: Boolean; EverythingPosted: Boolean)
    begin
    end;

    local procedure TestLine(LoanOrdHeader: Record "LM Loan Ord. Header"; LoanOrdLine: Record "LM Loan Ord. Line")
    begin
        OnTestLine(LoanOrdHeader, LoanOrdLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTestLine(var LoanOrdHeader: Record "LM Loan Ord. Header"; var LoanOrdLine: Record "LM Loan Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure UpdateLineBeforePost(LoanOrdHeader: Record "LM Loan Ord. Header"; LoanOrdLine: Record "LM Loan Ord. Line")
    begin
        OnUpdateLineBeforePost(LoanOrdHeader, LoanOrdLine, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateLineBeforePost(var LoanOrdHeader: Record "LM Loan Ord. Header"; var LoanOrdLine: Record "LM Loan Ord. Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure ClearAllVariables()
    begin
        ClearAll;
        TempLoanOrdLineGlobal.DeleteAll();
    end;

    procedure FillTempLines(LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLine: Record "LM Loan Ord. Line" temporary)
    begin
        TempLoanOrdLine.Reset();
        if TempLoanOrdLine.IsEmpty() then
            CopyToTempLines(LoanOrdHeader, TempLoanOrdLine);
    end;

    procedure CopyToTempLines(LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLine: Record "LM Loan Ord. Line" temporary)
    var
        LoanOrdLine: Record "LM Loan Ord. Line";
    begin
        LoanOrdLine.SetRange("Document No.", LoanOrdHeader."No.");
        OnCopyToTempLinesOnAfterSetFilters(LoanOrdLine, LoanOrdHeader);
        if LoanOrdLine.FindSet() then
            repeat
                TempLoanOrdLine := LoanOrdLine;
                TempLoanOrdLine.Insert();
            until LoanOrdLine.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyToTempLinesOnAfterSetFilters(var LoanOrdLine: Record "LM Loan Ord. Line"; LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforePostLines(var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
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

    local procedure PostHeader(LoanOrdHeader: Record "LM Loan Ord. Header"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header")
    begin
        OnPostHeader(LoanOrdHeader, PstdLoanOrdHeader, TempLoanOrdLineGlobal, SrcCode, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostHeader(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; SrcCode: Code[10]; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure CheckAndUpdate()
    begin
        // Check
        CheckMandatoryHeaderFields(LoanOrdHeader);
        CheckPostRestrictions(LoanOrdHeader);

        if not HideProgressWindow then
            InitProgressWindow(LoanOrdHeader);

        CheckNothingToPost(LoanOrdHeader);

        OnAfterCheckLoanOrd(LoanOrdHeader, SuppressCommit);

        // Update
        ModifyHeader := UpdatePostingNo(LoanOrdHeader);

        OnBeforePostCommitLoanOrd(LoanOrdHeader, PreviewMode, ModifyHeader, SuppressCommit, TempLoanOrdLineGlobal);
        if not PreviewMode and ModifyHeader then begin
            LoanOrdHeader.Modify();
            if not SuppressCommit then
                Commit();
        end;

        LockTables(LoanOrdHeader);

        SourceCodeSetup.Get();
        SrcCode := SourceCodeSetup."Loan Order";

        OnCheckAndUpdateOnAfterSetSourceCode(LoanOrdHeader, SourceCodeSetup, SrcCode);

        InsertPostedHeaders(LoanOrdHeader);

        OnAfterCheckAndUpdate(LoanOrdHeader, SuppressCommit, PreviewMode);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckAndUpdate(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
    end;

    local procedure InsertPostedHeaders(var LoanOrdHeader: Record "LM Loan Ord. Header")
    var
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        IsHandled: Boolean;
    begin
        if PreviewMode then
            PostingPreviewEventHandler.PreventCommit();

        PstdLoanOrdHeader.LockTable();

        IsHandled := false;
        OnBeforeInsertPstdLoanOrdHeader(LoanOrdHeader, IsHandled);
        if not IsHandled then
            InsertPstdLoanOrdHeader(LoanOrdHeader, PstdLoanOrdHeader);

        OnAfterInsertPstdLoanOrdHeader(LoanOrdHeader, PstdLoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPstdLoanOrdHeader(var LoanOrdHeader: Record "LM Loan Ord. Header"; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPstdLoanOrdHeader(var LoanOrdHeader: Record "LM Loan Ord. Header"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header")
    begin
    end;

    local procedure InsertPstdLoanOrdHeader(var LoanOrdHeader: Record "LM Loan Ord. Header"; var PstdLoanOrdHeader: Record "LM Posted Loan Order Header")
    var
        BookCommentLine: Record "LM Book Comment Line";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        PstdLoanOrdHeader.Init();
        PstdLoanOrdHeader.TransferFields(LoanOrdHeader);

        PstdLoanOrdHeader."No." := LoanOrdHeader."Posting No.";
        PstdLoanOrdHeader."No. Series" := LoanOrdHeader."Posting No. Series";
        PstdLoanOrdHeader."Loan Ord. No." := LoanOrdHeader."No.";
        PstdLoanOrdHeader."Loan Ord. Nos." := LoanOrdHeader."No. Series";
        if GuiAllowed and not HideProgressWindow then
            Window.Update(1, StrSubstNo(PostedLoanOrdNoMsg, LoanOrdHeader."No.", PstdLoanOrdHeader."No."));
        PstdLoanOrdHeader."Source Code" := SrcCode;
        PstdLoanOrdHeader."User ID" := UserId();
        PstdLoanOrdHeader."No. Printed" := 0;

        OnBeforePstdLoanOrdHeaderInsert(PstdLoanOrdHeader, LoanOrdHeader, SuppressCommit);
        PstdLoanOrdHeader.Insert(true);
        OnAfterPstdLoanOrdHeaderInsert(PstdLoanOrdHeader, LoanOrdHeader, SuppressCommit);

        if BookSetup."Copy Comments" then begin
            BookCommentLine.CopyComments(BookCommentLine."Document Type"::"Loan Order", BookCommentLine."Document Type"::"Posted Loan Order", LoanOrdHeader."No.", PstdLoanOrdHeader."No.");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePstdLoanOrdHeaderInsert(var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPstdLoanOrdHeaderInsert(var PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckAndUpdateOnAfterSetSourceCode(LoanOrdHeader: Record "LM Loan Ord. Header"; SourceCodeSetup: Record "Source Code Setup"; var SrcCode: Code[10]);
    begin
    end;

    local procedure LockTables(var LoanOrdHeader: Record "LM Loan Ord. Header")
    var
        LoanOrdLine: Record "LM Loan Ord. Line";
    begin
        OnBeforeLockTables(LoanOrdHeader, PreviewMode, SuppressCommit);

        LoanOrdLine.LockTable();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLockTables(var LoanOrdHeader: Record "LM Loan Ord. Header"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostCommitLoanOrd(var LoanOrdHeader: Record "LM Loan Ord. Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var CommitIsSuppressed: Boolean; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary)
    begin
    end;

    local procedure UpdatePostingNo(var LoanOrdHeader: Record "LM Loan Ord. Header") ModifyHeader: Boolean
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        OnBeforeUpdatePostingNo(LoanOrdHeader, PreviewMode, ModifyHeader, IsHandled);

        if not IsHandled then
            if LoanOrdHeader."Posting No." = '' then
                if not PreviewMode then begin
                    LoanOrdHeader.TestField("Posting No. Series");
                    LoanOrdHeader."Posting No." := NoSeriesMgt.GetNextNo(LoanOrdHeader."Posting No. Series", LoanOrdHeader."Posting Date", true);
                    ModifyHeader := true;
                end else
                    LoanOrdHeader."Posting No." := PostingPreviewNoTok;

        OnAfterUpdatePostingNo(LoanOrdHeader, NoSeriesMgt, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePostingNo(var LoanOrdHeader: Record "LM Loan Ord. Header"; PreviewMode: Boolean; var ModifyHeader: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdatePostingNo(var LoanOrdHeader: Record "LM Loan Ord. Header"; var NoSeriesMgt: Codeunit NoSeriesManagement; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckLoanOrd(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    procedure InitProgressWindow(LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
        Window.Open(
                '#1#################################\\' +
                  PostingLinesMsg);
        Window.Update(1, StrSubstNo('%1', LoanOrdHeader."No."));
    end;

    local procedure CheckMandatoryHeaderFields(var LoanOrdHeader: Record "LM Loan Ord. Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckMandatoryFields(LoanOrdHeader, SuppressCommit, IsHandled);
        if not IsHandled then begin
            LoanOrdHeader.TestField("Posting Date");
        end;

        OnAfterCheckMandatoryFields(LoanOrdHeader, SuppressCommit);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckMandatoryFields(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckMandatoryFields(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean)
    begin
    end;

    local procedure CheckPostRestrictions(LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
        OnCheckPostRestrictions(LoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostRestrictions(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

    local procedure CheckNothingToPost(LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
        OnCheckNothingToPost(LoanOrdHeader, TempLoanOrdLineGlobal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckNothingToPost(var LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostLoanOrd(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    begin
    end;

    local procedure GetBookSetup()
    begin
        if not BookSetupRead then
            BookSetup.Get;

        BookSetupRead := true;

        OnAfterGetBookSetup(BookSetup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetBookSetup(var BookSetup: Record "LM Book Setup")
    begin
    end;

}
