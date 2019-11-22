package eu.jpereira.trainings.designpatterns.structural.decorator.channel.decorator;

import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannel;

public class WordCensor extends SocialChannelDecorator {

    private String censoredWord = null;

    public WordCensor(String censoredWord){ this.censoredWord = censoredWord; }

    public WordCensor(String censoredWord, SocialChannel decoratedChannel){
        this.censoredWord = censoredWord;
        this.delegate = decoratedChannel;
    }

    @Override
    public void deliverMessage(String message) {
        delegate.deliverMessage(message.replaceAll(censoredWord,"###"));
    }
}
