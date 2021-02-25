page 50040 "LM Patient Setup"
{
    ApplicationArea = All;
    Caption = 'Patient Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "LM Patient Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
        	group(General)
        	{
        		Caption = 'General';
        		
        		field("Copy Comments"; "Copy Comments")
        		{
        			ApplicationArea = All;
        		}
        	}
            group("Number Series")
            {
                Caption = 'Number Series';

                field("Patient Nos."; "Patient Nos.")
                {
                    ApplicationArea = All;
                }
                field("Bld. Test Nos."; "Bld. Test Nos.")
                {
                	ApplicationArea = All;
                }
                field("Posted Bld. Test Nos."; "Posted Bld. Test Nos.")
                {
                	ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
