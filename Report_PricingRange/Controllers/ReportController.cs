﻿using Report_PricingRange.Business;
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


        public ActionResult ViewVehicles(string pstat = "",
                    string locd = "", string stckn = "", string Make = "", string mdlv = "", string mxyn = "", string crx = "",
                    string styln = "", string trmnm = "", string bDay = "", string yr = "")
        {
            var ViewVehiclesModel = new List<PricedVehicle>();
            ViewVehiclesModel = SqlQueries.GetVehicleList(ViewVehiclesModel, pstat, locd, stckn,  Make , mdlv, mxyn, crx,
                    styln, trmnm, bDay,yr);

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