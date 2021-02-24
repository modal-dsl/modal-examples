page 50023 "LM Book Card"
{
    Caption = 'Book Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,New Document,Book,Navigate';
    RefreshOnActivate = true;
    SourceTable = "LM Book";

    layout
    {
        area(content)
        {
        	group(General)
        	{
        		Caption = 'General';
        		
        		field("No."; "No.")
                {
                    ApplicationArea = All;
                    Importance = Standard;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
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
                field("Page Count"; "Page Count")
                {
                	ApplicationArea = All;
                }
                field("Release Date"; "Release Date")
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
                }
                field(LastDateModified; "Last Date Modified")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
        	}
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
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
            group("&Book")
            {
                Caption = '&Book';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Book),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(creation)
        {
        	action(NewLoanOrder)
        	{
        		AccessByPermission = tabledata "LM Loan Ord. Header" = RIM;
        		ApplicationArea = All;
        		Caption = 'Loan Order';
        		Image = NewDocument;
        		Promoted = true;
        		PromotedCategory = Category4;
        		RunObject = Page "LM Loan Order";
        		RunPageLink = "Book No." = field("No.");
        		RunPageMode = Create;
        		Visible = NOT IsOfficeAddin;
        	}
        }
    }

    var
        IsOfficeAddin: Boolean;

    local procedure ActivateFields()
    var
        OfficeManagement: Codeunit "Office Management";
    begin
        IsOfficeAddin := OfficeManagement.IsAvailable;
    end;
}
