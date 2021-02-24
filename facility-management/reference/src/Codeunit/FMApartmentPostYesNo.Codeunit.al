codeunit 50001 "FM Apartment-Post (Yes/No)"
{
    TableNo = "FM Wrk. Ord. Header";

    trigger OnRun()
    var
        WrkOrdHeader: Record "FM Wrk. Ord. Header";
    begin
        if not Find then
            Error(NothingToPostErr);

        WrkOrdHeader.Copy(Rec);
        Code(WrkOrdHeader);
        Rec := WrkOrdHeader;
    end;

    var
        PostConfirmQst: Label 'Do you want to post the %1?';
        NothingToPostErr: Label 'There is nothing to post.';

    local procedure "Code"(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforeConfirmPost(WrkOrdHeader, HideDialog, IsHandled);
        if IsHandled then
            exit;

        if not HideDialog then
            if not Confirm(PostConfirmQst, false, WrkOrdHeader.TableCaption) then
                exit;

        CODEUNIT.Run(CODEUNIT::"FM Apartment-Post", WrkOrdHeader);

        OnAfterPost(WrkOrdHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var WrkOrdHeader: Record "FM Wrk. Ord. Header")
    begin
    end;

}
