codeunit 50045 "LM Navigate Event Sub."
{
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
	var
		PstdBldTestHeader: Record "LM Posted Blood Test Header";
		Navigate: Page Navigate;
	begin
		If PstdBldTestHeader.ReadPermission then begin
			PstdBldTestHeader.SetFilter("No.", DocNoFilter);
			PstdBldTestHeader.SetFilter("Posting Date", PostingDateFilter);
			Navigate.InsertIntoDocEntry(DocumentEntry, Database::"LM Posted Blood Test Header", 0, 'Posted Blood Test', PstdBldTestHeader.Count);
		end;
	end;
	
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceCrMemoHeader: Record "Service Cr.Memo Header")
	var
		PstdBldTestHeader: Record "LM Posted Blood Test Header";
	begin
		if TableID <> Database::"LM Posted Blood Test Header" then
			exit;
		
		PstdBldTestHeader.SetFilter("No.", DocNoFilter);
		PstdBldTestHeader.SetFilter("Posting Date", PostingDateFilter);
		
		If (TempDocumentEntry."No. of Records" = 1) then
			PAGE.Run(PAGE::"LM Posted Blood Test", PstdBldTestHeader)
		else
			PAGE.Run(0, PstdBldTestHeader);
	end;
}
