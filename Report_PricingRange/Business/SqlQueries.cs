using Report_PricingRange.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Report_PricingRange.Business
{
    public class SqlQueries
    {

        public static ReportTemplateModel GetPriceReport(ReportTemplateModel leadReportModel, bool bReturnDeals = true)
        {

            var procedureName = "PricingRangeSum";

            var prices = SqlMapperUtil.StoredProcNOParams<PricedVehicle>(procedureName, "Rackspace"); 

            foreach (var price in prices)
            {
                if (price.LocationCode == null)
                {
                    price.LocationCode = "";
                }
            }

            //var associateAppointments = SqlMapperUtil.StoredProcWithParams<AssociateAppointment>("sp_CommissionGetAssociateAppointmentsByDate", new { StartDate = leadReportModel.ReportStartDate, EndDate = leadReportModel.ReportEndDate.AddDays(1) }, "SalesCommission");

            leadReportModel.Prices = prices;
            //leadReportModel.AssociateAppointments = associateAppointments;

            return leadReportModel;
        }

        public static List<PricedVehicle> GetVehicleList(List<PricedVehicle> ListPricedVehicle, string PriceStatus = "", 
                    string LocCode = "", string StockNum = "", string Make = "", string Modeln = "", string MatrixYN = "", string CRExpired = "",
                    string StyleName = "", string TrimName = "", string BucketDaysInInventory = "")
        {

            var procedureName = "PricingRangeVehicles";

            var prices = SqlMapperUtil.StoredProcWithParams <PricedVehicle>(procedureName, new {
                parPricingStatus = PriceStatus, parLoc = LocCode, StockNumber = StockNum, 
                        MakeName = Make, ModelName = Modeln, MatrixStatus = MatrixYN, CRExpired = CRExpired, StyleName = StyleName, 
                    TrimName = TrimName, BucketDaysInInventory = BucketDaysInInventory }, "Rackspace");

            //var associateLeads = SqlMapperUtil.StoredProcWithParams<AssociateLead>(procedureName, new { StartDate = leadReportModel.ReportStartDate, EndDate = leadReportModel.ReportEndDate }, "ReynoldsData"); //ReportEndDate.AddDays(1)


            foreach (var price in prices)
            {
                if (price.LocationCode == null)
                {
                    price.LocationCode = "";
                }
            }

            return prices;
        }
    }

}