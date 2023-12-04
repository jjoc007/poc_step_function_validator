function create() {
  const number = Math.floor(Math.random() * 100000000);
  console.log(`Number created: ${number}`);
  return number;
}

function finish(number) {
  console.log(`update finish over number: ${number}`);
  return 'finishing';
}

function rollback(number) {
  console.log(`update rollback over number: ${number}`);
  return 'rollbacking';
}

exports.handler = async event => {
  const action = event.action;
  console.log(`The Action is: ${action}`);

  if (action === 'create') {
    const number = create();
    const update = number % 2 === 0 ? 'finish' : 'rollback';
    return {number: number, update: update, status: 'in_progress'}
  } else if (action === 'execute_action'){
    const number = event.number;
    const update = event.update;
    let status = 'effective'

    if (status === 'effective') {
      if (update === 'finish') {
        status = finish(number);
      } else if (update === 'rollback') {
        status = rollback(number);
      } else {
        console.log(`The update is not valid: ${update}`);
        throw new Error("ExecuteAction_Error");
      }

      console.log(`The status is valid for finish/rollback curent: ${status}`);
      return {number: number, update: update, status: status}

    } else {
      console.log(`The status is not valid: ${status}`);
      throw new Error("ExecuteAction_Error");
    }

  } else if (action === 'end') {
    const number = event.number;
    const update = event.update;
    const status = event.update === 'finish' ? 'finished' : 'rollbacked';

    if(status === 'finished' && update === 'finish') {
      return {number: number, update: update, end: true}
    } else if (status === 'rollbacked' && update === 'rollback') {
      return {number: number, update: update, end: true}
    } else {
      console.log(`Incorrect terminated status Number: ${number} Status: ${status} with update: ${event.update}`);
      throw new Error("End_Error");
    }

  } else {
    console.log(`The action is not valid: ${action}`);
    return {action: action, valid: false}
  }
};
