/// <summary>
/// oh look a summary about codeunit 50305
/// </summary>
codeunit 50305 "TM3 FixedAssetPriceCalc."
{
    /// <summary>
    /// (option 1)OnBeforeUpdateUnitPrice.
    /// </summary>
    /// <param name="SalesLine">VAR Record "Sales Line".</param>
    /// <param name="xSalesLine">Record "Sales Line".</param>
    /// <param name="CalledByFieldNo">Integer.</param>
    /// <param name="CurrFieldNo">Integer.</param>
    /// <param name="Handled">VAR Boolean.</param>
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeUpdateUnitPrice', '', false, false)]
    local procedure OnBeforeUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer; var Handled: Boolean)
    begin
        if SalesLine.Type = SalesLine.Type::"Fixed Asset" then begin
            UpdateUnitPriceByField(SalesLine, CalledByFieldNo);
            Handled := true;
        end;
    end;
    /// <summary>
    /// (option 2)
    /// </summary>
    /// <param name="SalesLine"></param>
    /// <param name="AssetType"></param>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Line - Price", 'OnAfterGetAssetType', '', false, false)]
    local procedure OnAfterGetAssetType(SalesLine: Record "Sales Line"; var AssetType: Enum "Price Asset Type")
    begin
        if SalesLine.Type = SalesLine.Type::"Fixed Asset" then
            AssetType := AssetType::"TM3 FixedAsset";
    end;
    
    local procedure UpdateUnitPriceByField(var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        PriceCalculation: Interface "Price Calculation";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        SalesLine.TestField("Qty. per Unit of Measure");

        SalesLine.GetPriceCalculationHandler("Price Type"::Sale, SalesHeader, PriceCalculation);
        if not (SalesLine."Copied From Posted Doc." and SalesLine.IsCreditDocType()) then begin
            PriceCalculation.ApplyDiscount();
            SalesLine.ApplyPrice(CalledByFieldNo, PriceCalculation);

        end;

        SalesLine.Validate("Unit Price");
        SalesLine.ClearFieldCausedPriceCalculation();
    end;   
}
