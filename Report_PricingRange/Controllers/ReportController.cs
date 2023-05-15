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

            // add the Xrefid field to this for direct link
            string FitzMallURLVehicle = "https://responsive.fitzmall.com/Inventory/Detail/";


            return Redirect(FitzMallURLVehicle + keywordSearch) ;

        }

        public ActionResult MatrixInfo(string Location, string MakeCode, string ModelNumber, string Year)
        {

            // add the parameter fields to this for direct link
            string FitzMallURLVehicle = "http://jjfserver/asp/pricematrixedit1.asp?fx=edit&id=" + Location + MakeCode + ModelNumber + 
                    Year + "&mc=" + MakeCode + "&loc="+ Location +"&cntid=1";

            return Redirect(FitzMallURLVehicle);

        }

        public ActionResult ViewVehicleHistory(string vin = "")
        {
            var ViewVehicleHistory = new List<PricedVehicle>();

                ViewVehicleHistory = SqlQueries.GetVehicleHistory(ViewVehicleHistory, vin);

                ViewBag.vin = vin;
    
            return View(ViewVehicleHistory);

        }

        public ActionResult VehicleLeads(string stock = "")
        {
            var ViewVehicleLeads = new List<Lead>();

            ViewVehicleLeads = SqlQueries.GetLeadsByVehicle(ViewVehicleLeads, stock);

            ViewBag.stock = stock;

            return View(ViewVehicleLeads);

        }

        public ActionResult VehicleLeadsInVinSolutions(string searchval = "")
        {

            string FitzMallURLVehicle = "https://apps.vinmanager.com/vinconnect/#/Cardashboard/Pages/LeadManagement/ActiveLeadsLayout.aspx?SelectedTab=t_ILM&rightpaneframe=HIDE&leftpaneframe=AdvancedSearch2.aspx?searchdata=";
            FitzMallURLVehicle += searchval;

            return Redirect(FitzMallURLVehicle);

        }


        public ActionResult ViewVehicles(string pstat = "",
                    string locd = "", string stckn = "", string Make = "", string mdlv = "", string mxyn = "", string crx = "",
                    string styln = "", string trmnm = "", string bDay = "", string yr = "", string mc = "", string dt = "")
        {
            var ViewVehiclesModel = new List<PricedVehicle>();
            
                ViewVehiclesModel = SqlQueries.GetVehicleList(ViewVehiclesModel, pstat, locd, stckn,  Make , mdlv, mxyn, crx,
                    styln, trmnm, bDay, yr, mc);
 

            ViewBag.dt = dt;
            ViewBag.pstat = pstat;
            ViewBag.locd = locd;
            ViewBag.stckn = stckn;
            ViewBag.Make = Make;
            ViewBag.mdlv = mdlv;
            ViewBag.mxyn = mxyn;
            ViewBag.crexp = crx;
            ViewBag.styln = styln;
            ViewBag.trmnm= trmnm;
            ViewBag.bDay = bDay;
            ViewBag.yr = yr;
            ViewBag.mc = mc;
            return View(ViewVehiclesModel);
                        
        }
        public ActionResult TemplateReport()
        {
            var leadReportModel = new ReportTemplateModel();

            //            leadReportModel.ReportStartDate = DateTime.Now.AddMonths(-1);
            leadReportModel.ReportStartDate = DateTime.Now;
            leadReportModel.ReportEndDate = DateTime.Now;
            leadReportModel.IncludeStatus2InReport = true;


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

            bool IncludeStatus2 = true;
            if (Request.Form["Include2Chk"] == "on")
            {
                IncludeStatus2 = true;
            }
            else
            {
                IncludeStatus2 = false;
            }

            leadReportModel.ReportStartDate = startDate;
            leadReportModel.ReportEndDate = endDate;

            leadReportModel.IncludeStatus2InReport = IncludeStatus2;

            if (IncludeStatus2)
            {
                leadReportModel = SqlQueries.GetPriceReport(leadReportModel);
            } else
            {
                leadReportModel = SqlQueries.GetPriceReport(leadReportModel);
            }

            return View(leadReportModel);
        }


    }
}