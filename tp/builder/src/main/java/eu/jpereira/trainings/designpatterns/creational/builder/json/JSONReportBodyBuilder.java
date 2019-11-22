package eu.jpereira.trainings.designpatterns.creational.builder.json;

import eu.jpereira.trainings.designpatterns.creational.builder.ReportBodyBuilder;
import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.model.SoldItem;

import java.util.Iterator;

public class JSONReportBodyBuilder implements ReportBodyBuilder {

    private JSONReportBody reportBody = new JSONReportBody();

    @Override
    public void addCustomerInfo(String name, String phone) {
        reportBody.addContent("sale:{customer:{");
        reportBody.addContent("name:\"");
        reportBody.addContent(name);
        reportBody.addContent("\",phone:\"");
        reportBody.addContent(phone);
        reportBody.addContent("\"}");
    }

    @Override
    public void addItems(Iterator<SoldItem> it) {
        reportBody.addContent(",items:[");
        while ( it.hasNext() ) {
            SoldItem item = it.next();
            reportBody.addContent("{name:\"");
            reportBody.addContent(item.getName());
            reportBody.addContent("\",quantity:");
            reportBody.addContent(String.valueOf(item.getQuantity()));
            reportBody.addContent(",price:");
            reportBody.addContent(String.valueOf(item.getUnitPrice()));
            reportBody.addContent("}");
            if ( it.hasNext() ) {
                reportBody.addContent(",");
            }

        }
        reportBody.addContent("]}");
    }

    @Override
    public ReportBody getReportBody() {
        return reportBody;
    }
}
