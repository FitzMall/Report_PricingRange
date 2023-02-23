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

            var procedureName = "PricingRangeSumALLModels";

            var prices = SqlMapperUtil.StoredProcNOParams<PricedVehicle>(procedureName, "Rackspace"); 

            foreach (var price in prices)
            {
                if (price.LocationCode == null)
                {
                    price.LocationCode = "";
                }
                if (price.Trim == null)
                {
                    price.Trim = "";
                }
            }

            leadReportModel.Prices = prices;

            // supply
            procedureName = "PricingRangeSupply";

            var supply = SqlMapperUtil.StoredProcNOParams<PricedVehicle>(procedureName, "Rackspace");

            foreach (var car in supply)
            {
                if (car.LocationCode == null)
                {
                    car.LocationCode = "";
                }
            }

            leadReportModel.Prices = prices;
            leadReportModel.Supply = supply;

            return leadReportModel;
        }

        public static ReportTemplateModel GetPriceReport(ReportTemplateModel leadReportModel, DateTime DateOfReport ,bool bReturnDeals = true)
        {

            var procedureName = "PricingRangeSum_History";

            var prices = SqlMapperUtil.StoredProcWithParams<PricedVehicle>(procedureName, new { parDate = DateOfReport },"Rackspace");

            foreach (var price in prices)
            {
                if (price.LocationCode == null)
                {
                    price.LocationCode = "";
                }
            }

            leadReportModel.Prices = prices;

            return leadReportModel;
        }

        //[LastPriceChangesByVIN]

        public static List<PricedVehicle> GetVehicleList(List<PricedVehicle> ListPricedVehicle, string PriceStatus = "",
                    string LocCode = "", string StockNum = "", string Make = "", string Modeln = "", string MatrixYN = "", string CRExpired = "",
                    string StyleName = "", string TrimName = "", string BucketDaysInInventory = "", string ModelYear = "0", string ModelCode = "")
        {

            var procedureName = "PricingRangeVehicles";
            if (ModelYear == "")
            {
                ModelYear = "0";
            }

            var prices = SqlMapperUtil.StoredProcWithParams<PricedVehicle>(procedureName, new
            {
                parPricingStatus = PriceStatus,
                parLoc = LocCode,
                StockNumber = StockNum,
                MakeName = Make,
                ModelName = Modeln,
                MatrixStatus = MatrixYN,
                CRExpired = CRExpired,
                StyleName = StyleName,
                TrimName = TrimName,
                BucketDaysInInventory = BucketDaysInInventory,
                parModelYear = Int32.Parse(ModelYear),
                ModelCode = ModelCode
            }, "Rackspace");

            foreach (var price in prices)
            {
                if (price.LocationCode == null)
                {
                    price.LocationCode = "";
                }
            }

            return prices;
        }

        public static List<PricedVehicle> GetVehicleHistory(List<PricedVehicle> ListPricedVehicle, string Vin = "")
        {

            var procedureName = "PricingHistory_ByVin";
  
            var prices = SqlMapperUtil.StoredProcWithParams<PricedVehicle>(procedureName, new
            {
                parVin = Vin,
            }, "Rackspace");

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

        public static List<Lead> GetLeadsByVehicle(List<Lead> leads, string StockNumber = "")
        {
            var procedureName = "LeadsbyStockNumber";

            var prices = SqlMapperUtil.StoredProcWithParams<Lead>(procedureName, new
            {
                parStockNumber = StockNumber,
            }, "VINSolution");

            return prices;
        }


        public static List<PricedVehicle> GetVehicleList(List<PricedVehicle> ListPricedVehicle, string PriceStatus = "",
            string LocCode = "", string StockNum = "", string Make = "", string Modeln = "", string MatrixYN = "", string CRExpired = "",
            string StyleName = "", string TrimName = "", string BucketDaysInInventory = "", string ModelYear = "0", string ModelCode = "", string DatePast = "")
        {

            var procedureName = "PricingRangeVehicles";
            if (ModelYear == "")
            {
                ModelYear = "0";
            }

            var prices = SqlMapperUtil.StoredProcWithParams<PricedVehicle>(procedureName, new
            {
                parPricingStatus = PriceStatus,
                parLoc = LocCode,
                StockNumber = StockNum,
                MakeName = Make,
                ModelName = Modeln,
                MatrixStatus = MatrixYN,
                CRExpired = CRExpired,
                StyleName = StyleName,
                TrimName = TrimName,
                BucketDaysInInventory = BucketDaysInInventory,
                parModelYear = Int32.Parse(ModelYear),
                ModelCode = ModelCode
            }, "Rackspace");

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