codeunit 50003 "FM Apartment Jnl.-Post Line"
{
    Permissions = TableData "FM Work Order Entry" = imd,
                  TableData "FM Apartment Register" = imd;
    TableNo = "FM Apartment Journal Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        NextEntryNo: Integer;
        AptJnlLine: Record "FM Apartment Journal Line";
        partmentJnlCheckLine: Codeunit "FM Apartment Jnl.-Check Line";
        WrkOrdEntry: Record "FM Work Order Entry";
        ApartmentReg: Record "FM Apartment Register";
        Apt: Record "FM Apartment";

    procedure RunWithCheck(var AptJnlLine2: Record "FM Apartment Journal Line")
    begin
        AptJnlLine.Copy(AptJnlLine2);
        Code;
        AptJnlLine2 := AptJnlLine;
    end;

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        OnBeforePostJnlLine(AptJnlLine);

        if AptJnlLine.EmptyLine() then
            exit;

        partmentJnlCheckLine.RunCheck(AptJnlLine);

        if NextEntryNo = 0 then begin
            WrkOrdEntry.LockTable();
            NextEntryNo := WrkOrdEntry.GetLastEntryNo() + 1;
        end;

        if AptJnlLine."Document Date" = 0D then
            AptJnlLine."Document Date" := AptJnlLine."Posting Date";

        if ApartmentReg."No." = 0 then begin
            ApartmentReg.LockTable();
            if (not ApartmentReg.FindLast()) or (ApartmentReg."To Entry No." <> 0) then begin
                ApartmentReg.Init();
                ApartmentReg."No." := ApartmentReg."No." + 1;
                ApartmentReg."From Entry No." := NextEntryNo;
                ApartmentReg."To Entry No." := NextEntryNo;
                ApartmentReg."Creation Date" := Today();
                ApartmentReg."Creation Time" := Time();
                ApartmentReg."Source Code" := AptJnlLine."Source Code";
                ApartmentReg."Journal Batch Name" := AptJnlLine."Journal Batch Name";
                ApartmentReg."User ID" := UserId();
                ApartmentReg.Insert();
            end;
        end;
        ApartmentReg."To Entry No." := NextEntryNo;
        ApartmentReg.Modify();

        Apt.Get(AptJnlLine."Apartment No.");

        IsHandled := false;
        OnBeforeCheckAptBlocked(Apt, IsHandled);
        if not IsHandled then
            Apt.TestField(Blocked, false);

        WrkOrdEntry.Init();
        WrkOrdEntry.CopyFromAptJnlLine(AptJnlLine);

        WrkOrdEntry."User ID" := UserId();
        WrkOrdEntry."Entry No." := NextEntryNo;

        OnBeforeLedgerEntryInsert(WrkOrdEntry, AptJnlLine);

        WrkOrdEntry.Insert(true);

        NextEntryNo := NextEntryNo + 1;

        OnAfterPostJnlLine(AptJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJnlLine(var AptJnlLine: Record "FM Apartment Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckAptBlocked(Apt: Record "FM Apartment"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLedgerEntryInsert(var WrkOrdEntry: Record "FM Work Order Entry"; AptJnlLine: Record "FM Apartment Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostJnlLine(var AptJnlLine: Record "FM Apartment Journal Line")
    begin
    end;

}
