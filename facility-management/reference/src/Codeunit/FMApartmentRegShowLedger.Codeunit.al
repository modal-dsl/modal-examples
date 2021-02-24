codeunit 50004 "FM Apartment Reg.-Show Ledger"
{
    TableNo = "FM Apartment Register";

    trigger OnRun()
    begin
         WrkOrdEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
        PAGE.Run(PAGE::"FM Work Order Entries",  WrkOrdEntry);
    end;

    var
        WrkOrdEntry: Record "FM Work Order Entry";
}
