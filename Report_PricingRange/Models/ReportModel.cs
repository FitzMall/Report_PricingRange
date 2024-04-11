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

        public List<PricedVehicle> Supply { get; set; }

        public bool IncludeStatus2InReport { get; set; }

        public ReportType ReportType { get; set; }

    }

    public enum ReportType
    {
        Used = 0,
        New
    }


    public class Lead
    {
           
        public int  DealerID { get; set; }
          public int LeadID { get; set; }
          public string VOfInterest_InventoryType { get; set; }
        public string VOfInterest_StockNumber { get; set; }
        public string VOfInterest_VIN { get; set; }
        public int VOfInterest_Year { get; set; }
        public string VOfInterest_Make { get; set; }
        public string VOfInterest_Model { get; set; }
        public string VOfInterest_Trim { get; set; }
        public int VOfInterest_Odometer { get; set; }
        public double VOfInterest_Price { get; set; }
        public string TradeIn_RecordStatusCode { get; set; }
        public DateTime LastUpdatedUTCDate { get; set; }

        public DateTime FirstAttemptedContactUTCDate{ get; set; }
        public DateTime LastAttemptedContactUTCDate{ get; set; }
        public DateTime LastAttemptedEmailContactUTCDate{ get; set; }
        public DateTime LastAttemptedPhoneContactUTCDate{ get; set; }
        public DateTime LastCustomerContactUTCDate{ get; set; }
        public DateTime LastAttemptedOrActualContactUTCDate{ get; set; }
        public DateTime DealerActionableUTCDate{ get; set; }

        public string CustomerLastName{ get; set; }
        public string CustomerFirstName{ get; set; }
        public string CustomerType{ get; set; }
        public string CustomerStatus{ get; set; }
        public string CustomerMiddleName{ get; set; }
        public string CompanyName{ get; set; }
        public string PostalCode{ get; set; }
        public string DayTimePhone{ get; set; }
        public string DayTimePhoneExt{ get; set; }
        public string EveningPhone{ get; set; }
        public string EveningPhoneExt{ get; set; }
        public string CellPhone{ get; set; }
        public string Fax{ get; set; }
        public string Email{ get; set; }
        public string AlternateEmail{ get; set; }
        public string SalesMgrName{ get; set; }

        public int LeadStatusID{ get; set; }
        public string LeadStatusName{ get; set; }
        public string LeadStatusTypeName{ get; set; }
        public string LeadSourceName{ get; set; }
        public string LeadSourceTypeName{ get; set; }
        public string LeadSourceGroupName{ get; set; }
        public string SalesRepUserID{ get; set; }
        public string Sales_FirstName{ get; set; }
        public string Sales_LastName{ get; set; }
        public string Team{ get; set; }

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

        public DateTime RecDate { get; set; }

        public DateTime FDStartDate { get; set; }
        public DateTime FDEndDate { get; set; }
        public int FDAmount { get; set; }

        public int UnderMSRP { get; set; }
        public int OverInvoice { get; set; }

        public int Cars { get; set; }

        public int Leads { get; set; }
        public int Leads30 { get; set; }

        public int webviews { get; set; }

        public int InvoiceTotal { get; set; }

        // public DateTime LastPriceChangeDate { get; set; }

    }
}