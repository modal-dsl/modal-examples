page 50028 "LM Posted Loan Order List"
{
    ApplicationArea = All;
    Caption = 'Posted Loan Orders';
    CardPageID = "LM Posted Loan Order";
    DataCaptionFields = "Book No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Posted Loan Order,Navigate,Print/Send';
    RefreshOnActivate = true;
    SourceTable = "LM Posted Loan Order Header";
    SourceTableView = SORTING("Posting Date")
   	                  ORDER(Descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
            	ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Book No."; "Book No.")
                {
                    ApplicationArea = All;
                }
                field("Library User Code"; "Library User Code")
                {
                	ApplicationArea = All;
                }
                field("Loan Start"; "Loan Start")
                {
                	ApplicationArea = All;
                }
                field("Loan End"; "Loan End")
                {
                	ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
            	ApplicationArea = RecordLinks;
            	Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
            	ApplicationArea = Notes;
            }
        }
    }

	actions
    {
        area(navigation)
        {
            group("Posted Loan Order")
            {
                Caption = 'Posted Loan Order';
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "LM Book Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Posted Loan Order"),
                    			  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(processing)
        {
        	action(Navigate)
        	{
        		CaptionML = DEU = '&Navigate',
        					ENU = '&Navigate';
        		Image = Navigate;
        		Promoted = true;
        		PromotedCategory = Process;
        		
        		trigger OnAction()
        		begin
        			Navigate();
        		end;
        	}
        }
    }
}
