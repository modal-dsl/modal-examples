tableextension 50001 "FM Source Code Setup Ext" extends "Source Code Setup"
{
    fields
    {
        field(50010; "Work Order"; Code[10])
        {
            Caption = 'Work Order';
            TableRelation = "Source Code";
        }
    }
}
