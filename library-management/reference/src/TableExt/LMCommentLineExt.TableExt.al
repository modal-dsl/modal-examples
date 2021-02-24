tableextension 50020 "LM Comment Line Ext" extends "Comment Line"
{
	fields
	{
		modify("No.")
		{
			TableRelation = if ("Table Name" = const(Book)) "LM Book";
		}
	}
}
