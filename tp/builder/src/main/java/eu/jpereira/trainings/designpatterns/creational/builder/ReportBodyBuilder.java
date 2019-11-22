package eu.jpereira.trainings.designpatterns.creational.builder;

import eu.jpereira.trainings.designpatterns.creational.builder.model.Report;
import eu.jpereira.trainings.designpatterns.creational.builder.model.ReportBody;
import eu.jpereira.trainings.designpatterns.creational.builder.model.SaleEntry;
import eu.jpereira.trainings.designpatterns.creational.builder.model.SoldItem;

import java.util.Iterator;
import java.util.List;

public interface ReportBodyBuilder {
    void addCustomerInfo(String name,String phone);
    void addItems(Iterator<SoldItem> it);
    ReportBody getReportBody();
}
