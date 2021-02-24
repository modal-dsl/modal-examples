page 50027 "LM Loan Order"
{

    Caption = 'Loan Order';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Print/Send,Release,Posting,Loan Order,Navigate';
    RefreshOnActivate = true;
    SourceTable = "LM Loan Ord. Header";

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
                field("Book No."; "Book No.")
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
            part("LM Loan Ord. Subf."; "LM Loan Ord. Subf.")
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
            group("Loan Order")
            {
                Caption = 'Loan Order';
                Image = "Order";
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "LM Book Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Loan Order"),
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
                        ookPostYesNo: Codeunit "LM Book-Post (Yes/No)";
                    begin
                        ookPostYesNo.Run(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
