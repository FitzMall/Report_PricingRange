using Report_PricingRange.Business;
using Report_PricingRange.Models;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Report_PricingRange.Controllers
{
    public class ReportController : Controller
    {
        // GET: Report
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult GoToFitzMall(string keywordSearch)
        {

            return Redirect("https://responsive.fitzmall.com/Inventory/SearchResults?KeyWordSearch=" + keywordSearch + "&Sort=&inventoryGrid_length=10&UseCriteria=true");
        }


        public ActionResult ViewVehicles(string PricingStatus = "",
                    string LocCode = "", string StockNum = "", string Make = "", string Model = "", string MatrixYN = "")
        {
            var ViewVehiclesModel = new List<PricedVehicle>();
            ViewVehiclesModel = SqlQueries.GetVehicleList(ViewVehiclesModel, PricingStatus, LocCode ,  StockNum ,  Make ,  Model , MatrixYN );

            return View(ViewVehiclesModel);
        }
        public ActionResult TemplateReport()
        {
            var leadReportModel = new ReportTemplateModel();

            leadReportModel.ReportStartDate = DateTime.Now.AddMonths(-1);
            leadReportModel.ReportEndDate = DateTime.Now;


            return View(leadReportModel);
        }

        public ActionResult TemplateReport2()
        {
            var leadReportModel = new ReportTemplateModel();

            leadReportModel.ReportStartDate = DateTime.Now.AddMonths(-1);
            leadReportModel.ReportEndDate = DateTime.Now;


            return View(leadReportModel);
        }

        [HttpPost]
        public ActionResult TemplateReport(ReportTemplateModel leadReportModel)
        {

            if (Request.Form["breakdown1"] != null)
            {
                leadReportModel.BreakDownLevel1 = Request.Form["breakdown1"];
            }

            if (Request.Form["breakdown2"] != null)
            {
                leadReportModel.BreakDownLevel2 = Request.Form["breakdown2"];
            }

            if (Request.Form["breakdown3"] != null)
            {
                leadReportModel.BreakDownLevel3 = Request.Form["breakdown3"];
            }

            if (Request.Form["breakdown4"] != null)
            {
                leadReportModel.BreakDownLevel4 = Request.Form["breakdown4"];
            }

            var startDate = new DateTime();
            var endDate = new DateTime();

            if (Request.Form["datepickerStart"] != null)
            {
                startDate = Convert.ToDateTime(Request.Form["datepickerStart"]);
            }

            if (Request.Form["datepickerEnd"] != null)
            {
                endDate = Convert.ToDateTime(Request.Form["datepickerEnd"]);
            }


            leadReportModel.ReportStartDate = startDate;
            leadReportModel.ReportEndDate = endDate;

            leadReportModel = SqlQueries.GetPriceReport(leadReportModel, false);

            return View(leadReportModel);
        }

        public ActionResult DrillDown(string PricingStatus = "",
                    string LocCode = "", string StockNum = "", string Make = "", string Model = "", string MatrixYN = "")
        {

            

            return Redirect("ViewVehicles");

        }
    }
}