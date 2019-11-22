package eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty;

import eu.jpereira.trainings.designpatterns.structural.adapter.exceptions.CodeMismatchException;
import eu.jpereira.trainings.designpatterns.structural.adapter.exceptions.IncorrectDoorCodeException;
import eu.jpereira.trainings.designpatterns.structural.adapter.model.Door;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotChangeCodeForUnlockedDoor;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotChangeStateOfLockedDoor;
import eu.jpereira.trainings.designpatterns.structural.adapter.thirdparty.exceptions.CannotUnlockDoorException;

public class ThirdPartyDoorAdaper extends ThirdPartyDoor implements Door {

    @Override
    public void open(String code) throws IncorrectDoorCodeException {
        try {
            if (getLockStatus().equals(LockStatus.LOCKED)) {
                unlock(code);
            }
            setState(DoorState.OPEN);
        }
        catch (CannotUnlockDoorException e) {
            throw new IncorrectDoorCodeException();
        }
        catch (CannotChangeStateOfLockedDoor ignored) {}
    }

    @Override
    public void close() {
        try {
            if (isOpen()) {
                setState(DoorState.CLOSED);
            }
        }
        catch (CannotChangeStateOfLockedDoor ignored) {}
    }

    @Override
    public boolean isOpen() {
        return getState().equals(DoorState.OPEN);
    }

    @Override
    public void changeCode(String oldCode, String newCode, String newCodeConfirmation) throws IncorrectDoorCodeException, CodeMismatchException {
        if (!newCode.equals(newCodeConfirmation)) {
            throw new CodeMismatchException();
        }
        if (!testCode(oldCode)) {
            throw new IncorrectDoorCodeException();
        }
        try {
            if (getLockStatus().equals(LockStatus.LOCKED)) {
                unlock(oldCode);
            }
            setNewLockCode(newCode);
        }
        catch (CannotUnlockDoorException e){
            e.printStackTrace();
        }
        catch (CannotChangeCodeForUnlockedDoor e){
            e.printStackTrace();
        }
    }

    @Override
    public boolean testCode(String code) {
        boolean locked = true;
        if (getLockStatus().equals(LockStatus.UNLOCKED)) {
            lock();
            locked = false;
        }
        try {
            unlock(code);
            if (locked) {
                lock();;
            }
            return true;
        }
        catch (CannotUnlockDoorException e){
            return false;
        }
    }
}
