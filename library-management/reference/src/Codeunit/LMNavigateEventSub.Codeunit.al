codeunit 50025 "LM Navigate Event Sub."
{
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
	var
		PstdLoanOrdHeader: Record "LM Posted Loan Order Header";
		Navigate: Page Navigate;
	begin
		If PstdLoanOrdHeader.ReadPermission then begin
			PstdLoanOrdHeader.SetFilter("No.", DocNoFilter);
			PstdLoanOrdHeader.SetFilter("Posting Date", PostingDateFilter);
			Navigate.InsertIntoDocEntry(DocumentEntry, Database::"LM Posted Loan Order Header", 0, 'Posted Loan Order', PstdLoanOrdHeader.Count);
		end;
	end;
	
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceCrMemoHeader: Record "Service Cr.Memo Header")
	var
		PstdLoanOrdHeader: Record "LM Posted Loan Order Header";
	begin
		if TableID <> Database::"LM Posted Loan Order Header" then
			exit;
		
		PstdLoanOrdHeader.SetFilter("No.", DocNoFilter);
		PstdLoanOrdHeader.SetFilter("Posting Date", PostingDateFilter);
		
		If (TempDocumentEntry."No. of Records" = 1) then
			PAGE.Run(PAGE::"LM Posted Loan Order", PstdLoanOrdHeader)
		else
			PAGE.Run(0, PstdLoanOrdHeader);
	end;
}
