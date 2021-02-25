codeunit 50044 "LM Patient Reg.-Show Ledger"
{
    TableNo = "LM Patient Register";

    trigger OnRun()
    begin
         PatEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
        PAGE.Run(PAGE::"LM Patient Entries",  PatEntry);
    end;

    var
        PatEntry: Record "LM Patient Entry";
}
