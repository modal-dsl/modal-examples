pageextension 50000 "FM Source Code Setup Ext" extends "Source Code Setup"
{
    layout
    {
        addafter("Cost Accounting")
        {
            group("Facility Management")
            {
                Caption = 'Facility Management';

                field("Work Order"; "Work Order")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
