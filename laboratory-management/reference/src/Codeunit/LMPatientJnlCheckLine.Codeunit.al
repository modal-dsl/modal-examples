codeunit 50042 "LM Patient Jnl.-Check Line"
{
    TableNo = "LM Patient Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        CannotBeClosingDateErr: Label 'cannot be a closing date';

    procedure RunCheck(var PatJnlLine: Record "LM Patient Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunCheck(PatJnlLine, IsHandled);
        if IsHandled then
            exit;

        if PatJnlLine.EmptyLine then
            exit;

        PatJnlLine.TestField("Patient No.");
        PatJnlLine.TestField("Posting Date");

        CheckPostingDate(PatJnlLine);

        if PatJnlLine."Document Date" <> 0D then
            if PatJnlLine."Document Date" <> NormalDate(PatJnlLine."Document Date") then
                PatJnlLine.FieldError("Document Date", CannotBeClosingDateErr);

        OnAfterRunCheck(PatJnlLine);
    end;

    local procedure CheckPostingDate(PatJnlLine: Record "LM Patient Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        IsHandled: Boolean;
    begin
        if PatJnlLine."Posting Date" <> NormalDate(PatJnlLine."Posting Date") then
            PatJnlLine.FieldError("Posting Date", CannotBeClosingDateErr);

        IsHandled := false;
        OnCheckPostingDateOnBeforeCheckAllowedPostingDate(PatJnlLine."Posting Date", IsHandled);
        if IsHandled then
            exit;

        UserSetupManagement.CheckAllowedPostingDate(PatJnlLine."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var PatJnlLine: Record "LM Patient Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var PatJnlLine: Record "LM Patient Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingDateOnBeforeCheckAllowedPostingDate(PostingDate: Date; var IsHandled: Boolean);
    begin
    end;

}
