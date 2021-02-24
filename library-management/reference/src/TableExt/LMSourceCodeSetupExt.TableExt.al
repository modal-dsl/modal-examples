tableextension 50021 "LM Source Code Setup Ext" extends "Source Code Setup"
{
    fields
    {
        field(50000; "Loan Order"; Code[10])
        {
            Caption = 'Loan Order';
            TableRelation = "Source Code";
        }
    }
}
