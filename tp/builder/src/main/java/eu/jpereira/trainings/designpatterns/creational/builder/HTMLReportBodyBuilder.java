package eu.jpereira.trainings.designpatterns.creational.builder;

import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.model.SoldItem;

import java.util.Iterator;
import java.util.List;

public class HTMLReportBodyBuilder implements ReportBodyBuilder {

    private HTMLReportBody reportBody = new HTMLReportBody();

    @Override
    public void addCustomerInfo(String name, String phone) {
        reportBody.putContent("<span class=\"customerName\">");
        reportBody.putContent(name);
        reportBody.putContent("</span><span class=\"customerPhone\">");
        reportBody.putContent(phone);
        reportBody.putContent("</span>");
    }

    @Override
    public void addItems(Iterator<SoldItem> it) {
        reportBody.putContent("<items>");
        while ( it.hasNext() ) {
            SoldItem soldEntry= it.next();
            reportBody.putContent("<item><name>");
            reportBody.putContent(soldEntry.getName());
            reportBody.putContent("</name><quantity>");
            reportBody.putContent(soldEntry.getQuantity());
            reportBody.putContent("</quantity><price>");
            reportBody.putContent(soldEntry.getUnitPrice());
            reportBody.putContent("</price></item>");
        }
        reportBody.putContent("</items>");
    }

    @Override
    public ReportBody getReportBody() {
        return reportBody;
    }
}
