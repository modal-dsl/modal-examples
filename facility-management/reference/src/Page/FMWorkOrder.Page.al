page 50007 "FM Work Order"
{

    Caption = 'Work Order';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Print/Send,Release,Posting,Work Order,Navigate';
    RefreshOnActivate = true;
    SourceTable = "FM Wrk. Ord. Header";

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
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Apartment No."; "Apartment No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    QuickEntry = false;
                    Editable = true;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Posting Description"; "Posting Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Apt. Description"; "Apt. Description")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;

                }
                field("Apt. Description 2"; "Apt. Description 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Apt. Address"; "Apt. Address")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Apt. Address 2"; "Apt. Address 2")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Apt. City"; "Apt. City")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Apt. County"; "Apt. County")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Apt. Post Code"; "Apt. Post Code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Apt. Country/Region Code"; "Apt. Country/Region Code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Mt. Wk. Code"; "Mt. Wk. Code")
                {
                    ApplicationArea = All;
                }
                field("Mt. Wrk. Name"; "Mt. Wrk. Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;

                }
                field("Mt. Wrk. Name 2"; "Mt. Wrk. Name 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Finish Until"; "Finish Until")
                {
                    ApplicationArea = All;
                }
                field("Requested By"; "Requested By")
                {
                    ApplicationArea = All;
                }
            }
            part("FM Wrk. Ord. Subf."; "FM Wrk. Ord. Subf.")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
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
            group("Work Order")
            {
                Caption = 'Work Order';
                Image = "Order";
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "FM Apartment Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Work Order"),
                                  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Post)
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    var
                        partmentPostYesNo: Codeunit "FM Apartment-Post (Yes/No)";
                    begin
                        partmentPostYesNo.Run(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
