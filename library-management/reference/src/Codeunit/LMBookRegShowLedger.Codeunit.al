codeunit 50024 "LM Book Reg.-Show Ledger"
{
    TableNo = "LM Book Register";

    trigger OnRun()
    begin
         LoanEntry.SetRange("Entry No.", "From Entry No.", "To Entry No.");
        PAGE.Run(PAGE::"LM Loan Entries",  LoanEntry);
    end;

    var
        LoanEntry: Record "LM Loan Entry";
}
