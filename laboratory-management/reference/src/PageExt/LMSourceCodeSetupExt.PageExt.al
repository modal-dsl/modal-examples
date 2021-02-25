pageextension 50040 "LM Source Code Setup Ext" extends "Source Code Setup"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("Laboratory Management")
            {
                Caption = 'Laboratory Management';

                field("Blood Test"; "Blood Test")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
