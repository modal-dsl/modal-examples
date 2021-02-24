page 50020 "LM Book Setup"
{
    ApplicationArea = All;
    Caption = 'Book Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "LM Book Setup";
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

                field("Book Nos."; "Book Nos.")
                {
                    ApplicationArea = All;
                }
                field("Loan Ord. Nos."; "Loan Ord. Nos.")
                {
                	ApplicationArea = All;
                }
                field("Posted Loan Ord. Nos."; "Posted Loan Ord. Nos.")
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
