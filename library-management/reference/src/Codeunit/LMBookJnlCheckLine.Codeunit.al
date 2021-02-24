codeunit 50022 "LM Book Jnl.-Check Line"
{
    TableNo = "LM Book Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        CannotBeClosingDateErr: Label 'cannot be a closing date';

    procedure RunCheck(var BookJnlLine: Record "LM Book Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunCheck(BookJnlLine, IsHandled);
        if IsHandled then
            exit;

        if BookJnlLine.EmptyLine then
            exit;

        BookJnlLine.TestField("Book No.");
        BookJnlLine.TestField("Posting Date");

        CheckPostingDate(BookJnlLine);

        if BookJnlLine."Document Date" <> 0D then
            if BookJnlLine."Document Date" <> NormalDate(BookJnlLine."Document Date") then
                BookJnlLine.FieldError("Document Date", CannotBeClosingDateErr);

        OnAfterRunCheck(BookJnlLine);
    end;

    local procedure CheckPostingDate(BookJnlLine: Record "LM Book Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        IsHandled: Boolean;
    begin
        if BookJnlLine."Posting Date" <> NormalDate(BookJnlLine."Posting Date") then
            BookJnlLine.FieldError("Posting Date", CannotBeClosingDateErr);

        IsHandled := false;
        OnCheckPostingDateOnBeforeCheckAllowedPostingDate(BookJnlLine."Posting Date", IsHandled);
        if IsHandled then
            exit;

        UserSetupManagement.CheckAllowedPostingDate(BookJnlLine."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var BookJnlLine: Record "LM Book Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var BookJnlLine: Record "LM Book Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingDateOnBeforeCheckAllowedPostingDate(PostingDate: Date; var IsHandled: Boolean);
    begin
    end;

}
