codeunit 50021 "LM Book-Post (Yes/No)"
{
    TableNo = "LM Loan Ord. Header";

    trigger OnRun()
    var
        LoanOrdHeader: Record "LM Loan Ord. Header";
    begin
        if not Find then
            Error(NothingToPostErr);

        LoanOrdHeader.Copy(Rec);
        Code(LoanOrdHeader);
        Rec := LoanOrdHeader;
    end;

    var
        PostConfirmQst: Label 'Do you want to post the %1?';
        NothingToPostErr: Label 'There is nothing to post.';

    local procedure "Code"(var LoanOrdHeader: Record "LM Loan Ord. Header")
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforeConfirmPost(LoanOrdHeader, HideDialog, IsHandled);
        if IsHandled then
            exit;

        if not HideDialog then
            if not Confirm(PostConfirmQst, false, LoanOrdHeader.TableCaption) then
                exit;

        CODEUNIT.Run(CODEUNIT::"LM Book-Post", LoanOrdHeader);

        OnAfterPost(LoanOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var LoanOrdHeader: Record "LM Loan Ord. Header"; var HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var LoanOrdHeader: Record "LM Loan Ord. Header")
    begin
    end;

}
