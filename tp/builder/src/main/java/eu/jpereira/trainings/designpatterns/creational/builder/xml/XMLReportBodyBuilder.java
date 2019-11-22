package eu.jpereira.trainings.designpatterns.creational.builder.xml;

import eu.jpereira.trainings.designpatterns.creational.builder.ReportBodyBuilder;
import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.model.SoldItem;

import java.util.Iterator;

public class XMLReportBodyBuilder implements ReportBodyBuilder {

    private XMLReportBody reportBody = new XMLReportBody();

    @Override
    public void addCustomerInfo(String name, String phone) {
        reportBody.putContent("<sale><customer><name>");
        reportBody.putContent(name);
        reportBody.putContent("</name><phone>");
        reportBody.putContent(phone);
        reportBody.putContent("</phone></customer>");
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
        reportBody.putContent("</items></sale>");
    }

    @Override
    public ReportBody getReportBody() {
        return reportBody;
    }
}
