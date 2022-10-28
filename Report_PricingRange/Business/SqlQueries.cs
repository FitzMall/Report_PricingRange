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

            var procedureName = "PricingRange";

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

    }

}