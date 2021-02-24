codeunit 50002 "FM Apartment Jnl.-Check Line"
{
    TableNo = "FM Apartment Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        CannotBeClosingDateErr: Label 'cannot be a closing date';

    procedure RunCheck(var AptJnlLine: Record "FM Apartment Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeRunCheck(AptJnlLine, IsHandled);
        if IsHandled then
            exit;

        if AptJnlLine.EmptyLine then
            exit;

        AptJnlLine.TestField("Apartment No.");
        AptJnlLine.TestField("Posting Date");

        CheckPostingDate(AptJnlLine);

        if AptJnlLine."Document Date" <> 0D then
            if AptJnlLine."Document Date" <> NormalDate(AptJnlLine."Document Date") then
                AptJnlLine.FieldError("Document Date", CannotBeClosingDateErr);

        OnAfterRunCheck(AptJnlLine);
    end;

    local procedure CheckPostingDate(AptJnlLine: Record "FM Apartment Journal Line")
    var
        UserSetupManagement: Codeunit "User Setup Management";
        IsHandled: Boolean;
    begin
        if AptJnlLine."Posting Date" <> NormalDate(AptJnlLine."Posting Date") then
            AptJnlLine.FieldError("Posting Date", CannotBeClosingDateErr);

        IsHandled := false;
        OnCheckPostingDateOnBeforeCheckAllowedPostingDate(AptJnlLine."Posting Date", IsHandled);
        if IsHandled then
            exit;

        UserSetupManagement.CheckAllowedPostingDate(AptJnlLine."Posting Date");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var AptJnlLine: Record "FM Apartment Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var AptJnlLine: Record "FM Apartment Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckPostingDateOnBeforeCheckAllowedPostingDate(PostingDate: Date; var IsHandled: Boolean);
    begin
    end;

}
