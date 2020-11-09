using CrystalDecisions.Shared;
using CrystalDecisions.Web;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace crystalreport
{
    public partial class Report : System.Web.UI.Page
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {
            CrystalReportViewer1.ToolPanelView = ToolPanelViewType.None;
            var report = new Reports.HelloWorldReport();
            
            CrystalReportViewer1.ReportSource = report;
            CrystalReportViewer1.RefreshReport();
          
        }
    }
}