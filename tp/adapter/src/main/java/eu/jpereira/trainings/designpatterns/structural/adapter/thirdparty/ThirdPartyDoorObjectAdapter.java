package eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty;

import eu.jpereira.trainings.designpatterns.structural.adapter.exceptions.CodeMismatchException;
import eu.jpereira.trainings.designpatterns.structural.adapter.exceptions.IncorrectDoorCodeException;
import eu.jpereira.trainings.designpatterns.structural.adapter.model.Door;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotChangeCodeForUnlockedDoor;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotChangeStateOfLockedDoor;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotUnlockDoorException;

public class ThirdPartyDoorObjectAdapter implements Door {

    private ThirdPartyDoor door = new ThirdPartyDoor();

    /*
     * (non-Javadoc)
     *
     * @see
     * eu.jpereira.trainings.designpatterns.structural.adapter.model.DoorDriver
     * #open(java.lang.String)
     */
    @Override
    public void open(String code) throws IncorrectDoorCodeException {
        if (door.getState().equals(ThirdPartyDoor.DoorState.OPEN)) {
            return;
        }
        try {
            if (door.getLockStatus().equals(ThirdPartyDoor.LockStatus.LOCKED)) {
                door.unlock(code);
            }
            door.setState(ThirdPartyDoor.DoorState.OPEN);
        } catch (CannotUnlockDoorException e) {
            throw new IncorrectDoorCodeException();
        } catch (CannotChangeStateOfLockedDoor cannotChangeStateOfLockedDoor) {
            cannotChangeStateOfLockedDoor.printStackTrace();
        }

    }

    /*
     * (non-Javadoc)
     *
     * @see
     * eu.jpereira.trainings.designpatterns.structural.adapter.model.DoorDriver
     * #close()
     */
    @Override
    public void close() {
        try {
            door.setState(ThirdPartyDoor.DoorState.CLOSED);
        }
        catch (CannotChangeStateOfLockedDoor ignored){}
    }

    /*
     * (non-Javadoc)
     *
     * @see
     * eu.jpereira.trainings.designpatterns.structural.adapter.model.DoorDriver
     * #isOpen()
     */
    @Override
    public boolean isOpen() {
        return door.getState().equals(ThirdPartyDoor.DoorState.OPEN);
    }

    /*
     * (non-Javadoc)
     *
     * @see
     * eu.jpereira.trainings.designpatterns.structural.adapter.model.DoorDriver
     * #changeCode(java.lang.String, java.lang.String, java.lang.String)
     */
    @Override
    public void changeCode(String oldCode, String newCode, String newCodeConfirmation) throws IncorrectDoorCodeException, CodeMismatchException {

        if (!newCode.equals(newCodeConfirmation)) {
            throw new CodeMismatchException();
        }
        if (!testCode(oldCode)) {
            throw new IncorrectDoorCodeException();
        }
        try {
            if (door.getLockStatus().equals(ThirdPartyDoor.LockStatus.LOCKED)) {
                door.unlock(oldCode);
            }
            door.setNewLockCode(newCode);
        }
        catch (CannotUnlockDoorException e){
            e.printStackTrace();
        }
        catch (CannotChangeCodeForUnlockedDoor e){
            e.printStackTrace();
        }

    }

    /*
     * (non-Javadoc)
     *
     * @see
     * eu.jpereira.trainings.designpatterns.structural.adapter.model.DoorDriver
     * #testCode(java.lang.String)
     */
    @Override
    public boolean testCode(String code) {
        boolean locked = true;
        if (door.getLockStatus().equals(ThirdPartyDoor.LockStatus.UNLOCKED)) {
            door.lock();
            locked = false;
        }
        try {
            door.unlock(code);
            if (locked) {
                door.lock();;
            }
            return true;
        }
        catch (CannotUnlockDoorException e){
            return false;
        }
    }
}
