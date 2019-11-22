package eu.jpereira.trainings.designpatterns.structural.decorator.channel.decorator;

import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannel;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelBuilder;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelProperties;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.SocialChannelPropertyKey;
import eu.jpereira.trainings.designpatterns.structural.decorator.channel.spy.TestSpySocialChannel;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class ChainCensorDecoratorTest extends AbstractSocialChanneldDecoratorTest {

    @Test
    public void testCensorBeforeURLAppender(){
        // Create the builder
        SocialChannelBuilder builder = createTestSpySocialChannelBuilder();

        // create a spy social channel
        SocialChannelProperties props = new SocialChannelProperties().putProperty(SocialChannelPropertyKey.NAME, TestSpySocialChannel.NAME);

        // Chain decorators
        SocialChannel channel = builder.
                with(new WordCensor("jpereira")).
                with(new URLAppender("http://jpereira.eu")).
                getDecoratedChannel(props);

        channel.deliverMessage("this is jpereira");
        // Spy channel. Should get the one created before
        TestSpySocialChannel spyChannel = (TestSpySocialChannel) builder.buildChannel(props);
        assertEquals("this is ### http://jpereira.eu", spyChannel.lastMessagePublished());
    }

    @Test
    public void testCensorAfterURLAppender(){
        // Create the builder
        SocialChannelBuilder builder = createTestSpySocialChannelBuilder();

        // create a spy social channel
        SocialChannelProperties props = new SocialChannelProperties().putProperty(SocialChannelPropertyKey.NAME, TestSpySocialChannel.NAME);

        // Chain decorators
        SocialChannel channel = builder.
                with(new URLAppender("http://jpereira.eu")).
                with(new WordCensor("jpereira")).
                getDecoratedChannel(props);

        channel.deliverMessage("this is jpereira");
        // Spy channel. Should get the one created before
        TestSpySocialChannel spyChannel = (TestSpySocialChannel) builder.buildChannel(props);
        assertEquals("this is ### http://###.eu", spyChannel.lastMessagePublished());
    }

    @Test
    public void testCensorBeforeTruncator(){
        // Create the builder
        SocialChannelBuilder builder = createTestSpySocialChannelBuilder();

        // create a spy social channel
        SocialChannelProperties props = new SocialChannelProperties().putProperty(SocialChannelPropertyKey.NAME, TestSpySocialChannel.NAME);

        // Chain decorators
        SocialChannel channel = builder.
                with(new WordCensor("is a message")).
                with(new MessageTruncator(10)).
                getDecoratedChannel(props);

        channel.deliverMessage("this is a message");
        // Spy channel. Should get the one created before
        TestSpySocialChannel spyChannel = (TestSpySocialChannel) builder.buildChannel(props);
        assertEquals("this ###", spyChannel.lastMessagePublished());
    }

    @Test
    public void testCensorAfterTruncator(){
        // Create the builder
        SocialChannelBuilder builder = createTestSpySocialChannelBuilder();

        // create a spy social channel
        SocialChannelProperties props = new SocialChannelProperties().putProperty(SocialChannelPropertyKey.NAME, TestSpySocialChannel.NAME);

        // Chain decorators
        SocialChannel channel = builder.
                with(new MessageTruncator(10)).
                with(new WordCensor("is")).
                getDecoratedChannel(props);

        channel.deliverMessage("this is a message");
        // Spy channel. Should get the one created before
        TestSpySocialChannel spyChannel = (TestSpySocialChannel) builder.buildChannel(props);
        assertEquals("th### ###...", spyChannel.lastMessagePublished());
    }
}
