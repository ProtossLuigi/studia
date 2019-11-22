package eu.jpereira.trainings.designpatterns.creational.abstractfactory;

public interface AbstractReportElementsFactory {
    ReportBody createReportBody();
    ReportFooter createReportFooter();
    ReportHeader createReportHeader();
}
