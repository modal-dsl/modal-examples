page 50003 "FM Apartment Card"
{
    Caption = 'Apartment Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,New Document,Apartment,Navigate';
    RefreshOnActivate = true;
    SourceTable = "FM Apartment";

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
                field(Type; Type)
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
        	group(Building)
        	{
        		Caption = 'Building';
        		
        		field("Address"; "Address")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field("Address 2"; "Address 2")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field("City"; "City")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field("County"; "County")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field("Post Code"; "Post Code")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field("Country/Region Code"; "Country/Region Code")
        		{
        			ApplicationArea = All;
        			QuickEntry = false;
        		}
        		field(Floor; Floor)
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
            group("&Apartment")
            {
                Caption = '&Apartment';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Apartment),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(creation)
        {
        	action(NewWorkOrder)
        	{
        		AccessByPermission = tabledata "FM Wrk. Ord. Header" = RIM;
        		ApplicationArea = All;
        		Caption = 'Work Order';
        		Image = NewDocument;
        		Promoted = true;
        		PromotedCategory = Category4;
        		RunObject = Page "FM Work Order";
        		RunPageLink = "Apartment No." = field("No.");
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
