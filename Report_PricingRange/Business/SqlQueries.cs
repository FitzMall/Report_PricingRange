﻿using Report_PricingRange.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Report_PricingRange.Business
{
    public class SqlQueries
    {

        public static ReportTemplateModel GetPriceReport(ReportTemplateModel leadReportModel)
        {
            bool bIncludeStatus2 = leadReportModel.IncludeStatus2InReport;
            var procedureName = "PricingRangeSumALLModels_VehicleStatusBreakdown";

            if (leadReportModel.ReportType == ReportType.New) { 
                if (bIncludeStatus2)
                {
                    procedureName = "PricingRangeSumALLModels_VehicleStatusBreakdown";
                }
                else
                {
                    procedureName = "PricingRangeSumALLModelsEXCLUDEStatus2_VehicleStatusBreakdown";
                }
            } else
            {
                if (bIncludeStatus2)
                {
                    procedureName = "PricingRangeUSED_SumALLModels_VehicleStatusBreakdown";
                }
                else
                {
                    procedureName = "PricingRangeUSED_SumALLModelsEXCLUDEStatus2_VehicleStatusBreakdown";
                }
            }

            var prices = SqlMapperUtil.StoredProcNOParams<PricedVehicle>(procedureName, "FITZWAY"); 

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
            if(leadReportModel.ReportType == ReportType.Used)
            {
                procedureName = "PricingRangeUSED_Supply";
            }

            var supply = SqlMapperUtil.StoredProcNOParams<PricedVehicle>(procedureName, "FITZWAY");

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

            var prices = SqlMapperUtil.StoredProcWithParams<PricedVehicle>(procedureName, new { parDate = DateOfReport },"FITZWAY");

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
                    string StyleName = "", string TrimName = "", string BucketDaysInInventory = "", string ModelYear = "0", string ModelCode = "",
                    bool ExcludeStatus2 = false, int vs = 0, ReportType usedOrNew = ReportType.New)
        {

            var procedureName = "PricingRangeVehicles";


            if (usedOrNew == ReportType.New)
            {
                procedureName = "PricingRangeVehicles";

                if (ExcludeStatus2)
                {
                    procedureName = "PricingRangeVehiclesEXCLUDEStatus2";
                }
            } else
            {
                procedureName = "PricingRangeUSED_Vehicles";

                if (ExcludeStatus2)
                {
                    procedureName = "PricingRangeUSED_VehiclesEXCLUDEStatus2";
                }
            }

            // in FitzWay on .16
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
                ModelCode = ModelCode,
                VehicleStatus = vs
            }, "FITZWAY");

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
            }, "FITZWAY");

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
            string StyleName = "", string TrimName = "", string BucketDaysInInventory = "", string ModelYear = "0", string ModelCode = ""
            , string DatePast = "", ReportType usedOrNew = ReportType.New)
        {

            var procedureName = "PricingRangeVehicles";
            if(usedOrNew == ReportType.Used)
            {
                procedureName = "PricingRangeUSED_Vehicles";
            }

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
            }, "FITZWAY");

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