codeunit 50041 "LM Patient-Post (Yes/No)"
{
    TableNo = "LM Bld. Test Header";

    trigger OnRun()
    var
        BldTestHeader: Record "LM Bld. Test Header";
    begin
        if not Find then
            Error(NothingToPostErr);

        BldTestHeader.Copy(Rec);
        Code(BldTestHeader);
        Rec := BldTestHeader;
    end;

    var
        PostConfirmQst: Label 'Do you want to post the %1?';
        NothingToPostErr: Label 'There is nothing to post.';

    local procedure "Code"(var BldTestHeader: Record "LM Bld. Test Header")
    var
        HideDialog: Boolean;
        IsHandled: Boolean;
    begin
        HideDialog := false;
        IsHandled := false;
        OnBeforeConfirmPost(BldTestHeader, HideDialog, IsHandled);
        if IsHandled then
            exit;

        if not HideDialog then
            if not Confirm(PostConfirmQst, false, BldTestHeader.TableCaption) then
                exit;

        CODEUNIT.Run(CODEUNIT::"LM Patient-Post", BldTestHeader);

        OnAfterPost(BldTestHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var BldTestHeader: Record "LM Bld. Test Header"; var HideDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPost(var BldTestHeader: Record "LM Bld. Test Header")
    begin
    end;

}
