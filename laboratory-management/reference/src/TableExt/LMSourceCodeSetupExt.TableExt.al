tableextension 50041 "LM Source Code Setup Ext" extends "Source Code Setup"
{
    fields
    {
        field(50000; "Blood Test"; Code[10])
        {
            Caption = 'Blood Test';
            TableRelation = "Source Code";
        }
    }
}
