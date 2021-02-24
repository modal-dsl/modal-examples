codeunit 50036 "LM Library Mgt. Event Sub."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book-Post", 'OnBeforePostedLineInsert', '', true, false)]
    local procedure BookPostOnBeforePostedLineInsert(var PstdLoanOrdLine: Record "LM Posted Loan Order Line"; PstdLoanOrdHeader: Record "LM Posted Loan Order Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary; LoanOrdHeader: Record "LM Loan Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    var
        BookJnlLine: Record "LM Book Journal Line";
        BookJnlPostLine: Codeunit "LM Book Jnl.-Post Line";
    begin
        BookJnlLine.Init();
        BookJnlLine."Book No." := LoanOrdHeader."Book No.";
        BookJnlLine."Posting Date" := LoanOrdHeader."Posting Date";
        BookJnlLine."Document Date" := LoanOrdHeader."Document Date";
        BookJnlLine."Document No." := PstdLoanOrdHeader."No.";
        BookJnlLine."Loan Order No." := LoanOrdHeader."No.";
        BookJnlLine."Source No." := LoanOrdHeader."Book No.";
        BookJnlLine."Source Code" := SrcCode;
        BookJnlLine."Reason Code" := LoanOrdHeader."Reason Code";
        BookJnlLine."Posting No. Series" := LoanOrdHeader."Posting No. Series";
        BookJnlLine."Library User Code" := LoanOrdHeader."Library User Code";
        BookJnlLine."Event Date" := TempLoanOrdLineGlobal."Event Date";
        BookJnlLine."Event Type" := TempLoanOrdLineGlobal."Event Type";
        BookJnlLine.Description := TempLoanOrdLineGlobal.Description;
        BookJnlPostLine.RunWithCheck(BookJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book-Post", 'OnCheckNothingToPost', '', true, false)]
    local procedure BookPostOnCheckNothingToPost(var LoanOrdHeader: Record "LM Loan Ord. Header"; var TempLoanOrdLineGlobal: Record "LM Loan Ord. Line" temporary)
    var
        NothingToPostErr: Label 'There is nothing to post.';
    begin
        if TempLoanOrdLineGlobal.IsEmpty() then
            Error(NothingToPostErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book-Post", 'OnAfterCheckMandatoryFields', '', true, false)]
    local procedure BookPostOnAfterCheckMandatoryFields(var LoanOrdHeader: Record "LM Loan Ord. Header"; CommitIsSuppressed: Boolean)
    begin
        LoanOrdHeader.TestField(Status, LoanOrdHeader.Status::Finished);
        LoanOrdHeader.TestField("Book No.");
        LoanOrdHeader.TestField("Library User Code");
        LoanOrdHeader.TestField("Loan Start");
        LoanOrdHeader.TestField("Loan End");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book-Post", 'OnTestLine', '', true, false)]
    local procedure BookPostOnTestLine(var LoanOrdHeader: Record "LM Loan Ord. Header"; var LoanOrdLine: Record "LM Loan Ord. Line"; CommitIsSuppressed: Boolean)
    begin
        LoanOrdLine.TestField("Event Date");
        LoanOrdLine.TestField(Description);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book Jnl.-Check Line", 'OnAfterRunCheck', '', true, false)]
    local procedure BookJnlCheckLineOnAfterRunCheck(var BookJnlLine: Record "LM Book Journal Line")
    begin
        BookJnlLine.TestField("Document No.");
        BookJnlLine.TestField("Loan Order No.");
        BookJnlLine.TestField("Book No.");
        BookJnlLine.TestField("Library User Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Book Jnl.-Post Line", 'OnBeforePostJnlLine', '', true, false)]
    local procedure BookJnlPostLineOnBeforePostJnlLine(var BookJnlLine: Record "LM Book Journal Line")
    var
        Book: Record "LM Book";
        LibraryUser: Record "LM Library User";
    begin
        BookJnlLine.TestField("Book No.");
        Book.Get(BookJnlLine."Book No.");
        Book.TestField(Blocked, false);

        BookJnlLine.TestField("Library User Code");
        LibraryUser.Get(BookJnlLine."Library User Code");
        LibraryUser.TestField(Blocked, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LM Loan Entry", 'OnAfterCopyLoanEntryFromBookJnlLine', '', true, false)]
    local procedure LoanEntryOnAfterCopyLoanEntryFromBookJnlLine(var LoanEntry: Record "LM Loan Entry"; var BookJnlLine: Record "LM Book Journal Line")
    begin
        LoanEntry."Library User Code" := BookJnlLine."Library User Code";
        LoanEntry."Event Date" := BookJnlLine."Event Date";
        LoanEntry."Event Type" := BookJnlLine."Event Type";
        LoanEntry."Loan Order No." := BookJnlLine."Loan Order No.";
    end;

}
