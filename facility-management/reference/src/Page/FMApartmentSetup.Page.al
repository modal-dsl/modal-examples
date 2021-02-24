page 50000 "FM Apartment Setup"
{
    ApplicationArea = All;
    Caption = 'Apartment Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "FM Apartment Setup";
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

                field("Apartment Nos."; "Apartment Nos.")
                {
                    ApplicationArea = All;
                }
                field("Wrk. Ord. Nos."; "Wrk. Ord. Nos.")
                {
                	ApplicationArea = All;
                }
                field("Posted Wrk. Ord. Nos."; "Posted Wrk. Ord. Nos.")
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
