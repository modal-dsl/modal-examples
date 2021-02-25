page 50043 "LM Patient Card"
{
    Caption = 'Patient Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,New Document,Patient,Navigate';
    RefreshOnActivate = true;
    SourceTable = "LM Patient";

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
                field("Name"; "Name")
                {
                	ApplicationArea = All;
                	Importance = Promoted;
                	ShowMandatory = true;
                	
                	trigger OnValidate()
                	begin
                		CurrPage.SaveRecord;
                	end;
                }
                field("Name 2"; "Name 2")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                	Visible = false;
                }
                field("Search Name"; "Search Name")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                }
                field(Gender; Gender)
                {
                	ApplicationArea = All;
                }
                field(Birthday; Birthday)
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
        	group("Contact Information")
        	{
        		Caption = 'Contact Information';
        		
        		field("Phone No."; "Phone No.")
        		{
        			ApplicationArea = All;
        		}
        		field("Telex No."; "Telex No.")
        		{
        			ApplicationArea = All;
        			Visible = false;
        		}
        		field("Fax No."; "Fax No.")
        		{
        			ApplicationArea = All;
        			Visible = false;
        		}
        		field("Telex Answer Back"; "Telex Answer Back")
        		{
        			ApplicationArea = All;
        			Visible = false;
        		}
        		field("E-Mail"; "E-Mail")
        		{
        			ApplicationArea = All;
        		}
        		field("Home Page"; "Home Page")
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
            group("&Patient")
            {
                Caption = '&Patient';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Patient),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(creation)
        {
        	action(NewBloodTest)
        	{
        		AccessByPermission = tabledata "LM Bld. Test Header" = RIM;
        		ApplicationArea = All;
        		Caption = 'Blood Test';
        		Image = NewDocument;
        		Promoted = true;
        		PromotedCategory = Category4;
        		RunObject = Page "LM Blood Test";
        		RunPageLink = "Patient No." = field("No.");
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
