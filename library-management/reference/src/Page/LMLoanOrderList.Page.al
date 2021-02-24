page 50026 "LM Loan Order List"
{
    ApplicationArea = All;
    Caption = 'Loan Orders';
    CardPageID = "LM Loan Order";
    DataCaptionFields = "Book No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Posting,Print/Send,Loan Order,Navigate';
    SourceTable = "LM Loan Ord. Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
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
            group("Loan Order")
            {
                Caption = 'Loan Order';
                Image = "Order";
                action("&Book Card")
                {
                    ApplicationArea = All;
                    Caption = '&Book Card';
                    RunObject = Page "LM Book Card";
                    RunPageLink = "No." = FIELD("Book No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the Book.';
                }
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "LM Book Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Loan Order"),
                    			  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
