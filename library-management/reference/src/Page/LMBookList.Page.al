page 50024 "LM Book List"
{
    ApplicationArea = All;
    Caption = 'Books';
    CardPageID = "LM Book Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Book,Navigate';
    SourceTable = "LM Book";
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
                }
                field("Description"; "Description")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    
                    trigger OnValidate()
                    begin
                    	CurrPage.SaveRecord;
                    end;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Search Description"; "Search Description")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                }
                field("Book Type"; "Book Type")
                {
                	ApplicationArea = All;
                }
                field(Author; Author)
                {
                	ApplicationArea = All;
                }
                field(Genre; Genre)
                {
                	ApplicationArea = All;
                }
                field("Language Code"; "Language Code")
                {
                	ApplicationArea = All;
                }
                field(Publisher; Publisher)
                {
                	ApplicationArea = All;
                }
                field(ISBN; ISBN)
                {
                	ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Visible = false;
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
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Book")
            {
                Caption = '&Book';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Book),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
