pageextension 50020 "LM Source Code Setup Ext" extends "Source Code Setup"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("Library Management")
            {
                Caption = 'Library Management';

                field("Loan Order"; "Loan Order")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
