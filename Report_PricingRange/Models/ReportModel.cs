using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Report_PricingRange.Models
{
    public class ReportTemplateModel
    {
        public string BreakDownLevel1 { get; set; }
        public string BreakDownLevel2 { get; set; }
        public string BreakDownLevel3 { get; set; }
        public string BreakDownLevel4 { get; set; }
        public DateTime ReportStartDate { get; set; }
        public DateTime ReportEndDate { get; set; }
        public List<PricedVehicle> Prices { get; set; }
    }

    public class PricedVehicle
    {
        public int Id { get; set; }
        public string VehicleStatus { get; set; }
        public string StockNumber { get; set; }
        public string VehicleCondition { get; set; }
        public string LocationCode { get; set; }
        public string MakeCode { get; set; }
        public string MakeName { get; set; }
        public string ModelCode { get; set; }
        public string ModelName { get; set; }
        public string Vin { get; set; }
        public int InternetPrice { get; set; }
        public int DeliveredPrice { get; set; }
        public int InvoicePrice { get; set; }
        public int MSRPPrice { get; set; }
        public int KBBPrice { get; set; }
        public string MatrixPricing { get; set; }
        public int MAPPrice { get; set; }
        public int LowestMAAPPrice { get; set; }
        public int CRAmount { get; set; }

        public string PricingStatus { get; set; }

        public string S_LOCCODE { get; set; }

        public string Xrefid { get; set; }
        public string CRExpired { get; set; }

        public string BucketDaysInInventory { get; set; }
        public string StyleName { get; set; }
        public string Trim { get; set; }
        public int DAYSININVENTORY { get; set; }
        public float PercentageMSRP { get; set; }
        public DateTime CREndDate { get; set; }
        public int ModelYear { get; set; }
        public string ModelYearString { get; set; }

        public decimal Markup { get; set; }
        public string MSRPInvoiceFlag { get; set; }

        public string RecDate { get; set; }

        // public DateTime LastPriceChangeDate { get; set; }

    }
}